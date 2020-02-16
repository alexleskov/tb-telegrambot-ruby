require './models/user'
require './models/api_token'
require './models/profile'
require './models/course_session'
require './models/section'
require './models/material'
require './models/quiz'
require './models/scorm_package'
require './models/task'

require 'encrypted_strings'

module Teachbase
  module Bot
    class DataLoader
      MAX_RETRIES = 3
      CS_STATES = %i[active archived].freeze
      SECTIONS_CONTENT = { materials: %i[name category],
                           scorm_packages: %i[],
                           quizzes: %i[name],
                           tasks: %i[name] }.freeze
      OBJECTS = { user: %i[last_name phone email avatar_url],
                  profile: %i[active_courses_count average_score_percent archived_courses_count total_time_spent],
                  course_session: %i[name icon_url bg_url deadline listeners_count progress started_at
                                     can_download success started_at can_download success full_access
                                     application_status navigation rating has_certificate],
                  sections: %i[name opened_at is_publish is_available] }.freeze

      attr_reader :apitoken, :user, :appshell, :authsession

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @tg_user = appshell.controller.respond.incoming_data.tg_user
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @logger = AppConfigurator.new.get_logger
        @retries = 0
      end

      def get_cs_info(cs_id)
        get_data { user.course_sessions.find_by(tb_id: cs_id) }
      end

      def get_user_profile
        get_data { user.profile }
      end

      def get_cs_list(state, limit_count, offset_num)
        get_data { user.course_sessions.order(name: :asc).limit(limit_count).offset(offset_num).where(complete_status: state.to_s,
                                                     scenario_mode: appshell.settings.scenario) }
      end

      def get_cs_sec_list(cs_id)
        get_data { get_cs_info(cs_id).sections.order(position: :asc) }
      end

      def get_cs_sec(section_position, cs_id)
        get_data do
          user.course_sessions.find_by(tb_id: cs_id).sections.find_by(position: section_position)
        end
      end

      def get_cs_sec_content(section_bd)
        return unless section_bd

        section_content = {}
        get_data do
          SECTIONS_CONTENT.keys.each do |content_type|
            section_content[content_type] = section_bd.public_send(content_type).order(position: :asc)
          end
        end
        section_content
      end

      def call_profile
        call_data do
          lms_info = authsession.load_profile
          raise "Profile is not loaded" unless lms_info

          profile = Teachbase::Bot::Profile.find_or_create_by!(user_id: user.id)
          user.update!(create_attributes(OBJECTS[:user], lms_info).merge!(tb_id: lms_info["id"], first_name: lms_info["name"]))
          profile.update!(create_attributes(OBJECTS[:profile], lms_info))
        end
      end

      def call_cs_list(state)
        raise "No such option for update course sessions list" unless CS_STATES.include?(state.to_sym)

        call_data do
          lms_info = authsession.load_course_sessions(state)
          #@logger.debug "lms_info: #{lms_info}"
          lms_info.each do |course_session|
            cs = user.course_sessions.find_by(tb_id: course_session["id"],
                                              changed_at: course_session["updated_at"])
            unless cs
              user.course_sessions.create!(create_attributes(OBJECTS[:course_session], course_session)
                                  .merge!(tb_id: course_session["id"],
                                          changed_at: course_session["updated_at"],
                                          complete_status: state.to_s))
            end
          end
        end
      end

      def call_cs_info(cs_id)
        call_data do
          authsession.load_cs_info(cs_id)
        end
      end

      def call_cs_sections(cs_id)
        call_data do
          return if course_session_last_version?(cs_id) && !course_session_last_version?(cs_id).sections.empty?

          course_session = user.course_sessions.find_or_create_by!(tb_id: cs_id, user_id: user.id)
          #@request_loader = Async do |task|
            authsession.load_cs_info(cs_id)["sections"].each_with_index do |section_lms, ind|
              section_bd = course_session.sections.find_or_create_by!(position: ind + 1)
              SECTIONS_CONTENT.keys.each do |type|
                custom_params = case type
                                when :materials
                                  {content_type: "type"}
                                when :scorm_packages
                                  {name: "title"}
                                end
                fetch_content(type.to_s, section_lms, section_bd, SECTIONS_CONTENT[type], param = custom_params || {})
              end
              section_bd.update!(create_attributes(OBJECTS[:sections], section_lms).merge!(user_id: user.id))
            end
          #end
        end
      end

      def load_models
        auth_checker unless authsession?
        @apitoken = Teachbase::Bot::ApiToken.find_by(auth_session_id: authsession.id, active: true)
        raise unless apitoken
        
        authsession.api_auth(:mobile_v2, access_token: apitoken.value)
        @user = authsession.user
      rescue RuntimeError
        auth_checker
        retry
      end

      def unauthorize
        return unless authsession?

        authsession.update!(active: false)
      end

      def auth_checker
        authsession?(:with_create)
        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id)
        if apitoken.avaliable?
          authsession.api_auth(:mobile_v2, access_token: apitoken.value)
        else
          authsession.update!(active: false)
          login_by_user_data
        end
        return unless authsession.active?
        @user = authsession.user
      end

      private

      def authsession?(option = {})
        @authsession = case option
                       when :with_create
                         @tg_user.auth_sessions.find_or_create_by!(active: true)
                       else
                         @tg_user.auth_sessions.find_by(active: true)
                       end
      end

      def get_data
        load_models
        yield
      end

      def call_data
        load_models
        yield
      rescue RuntimeError => e
        if e.http_code == 401 || e.http_code == 403
          auth_checker
          retry
        elsif (@retries += 1) <= MAX_RETRIES
          @logger.debug "#{e}\n#{I18n.t('retry')} №#{@retries}.."
          sleep(@retries)
          retry
        else
          @logger.debug "Unexpected error after retries: #{e}. code: #{e.http_code}"
          appshell.controller.answer.send_out "#{I18n.t('unexpected_error')}: #{e}"
        end
      end

      def course_session_last_version?(cs_id)
        user.course_sessions.find_by(tb_id: cs_id, changed_at: call_cs_info(cs_id)["updated_at"])
      end

      def fetch_content(conten_type, section_lms, section_bd, params, custom_params = {})
        raise "No such content type: #{conten_type}." unless section_bd.respond_to? conten_type

        section_lms[conten_type.to_s].each do |object|
          custom_data = custom_params.empty? ? {} : create_custom_params(custom_params, object)
          section_bd.public_send(conten_type)
                    .find_or_create_by!(position: object["position"], tb_id: object["id"],
                                        course_session_id: section_bd.course_session.id, user_id: user.id)
                    .update!(create_attributes(params, object).merge!(custom_data))
        end
      end

      def create_custom_params(custom_params, lms_data_object)
        custom_data = {}
        custom_params.each do |key, value|
          custom_data.merge!({key => lms_data_object[value.to_s]})
        end
        custom_data
      end

      def login_by_user_data
        user_data = request_user_data
        raise if user_data.any?(nil)

        login = user_data.first
        password = user_data.second
        crypted_password = password.encrypt(:symmetric, password: @encrypt_key)
        authsession.api_auth(:mobile_v2, user_login: login, password: crypted_password.decrypt)
        raise "Can't authorize authsession id: #{authsession.id}. Token value: #{authsession.tb_api.token.value}" unless authsession.tb_api.token.value

        apitoken.update!(version: authsession.tb_api.token.version,
                         grant_type: authsession.tb_api.token.grant_type,
                         expired_at: authsession.tb_api.token.expired_at,
                         value: authsession.tb_api.token.value,
                         active: true)
        raise "Can't load API Token" unless apitoken

        @user = Teachbase::Bot::User.find_or_create_by!(appshell.kind_of_login(login) => login)

        user.update!(password: crypted_password)
        authsession.update!(auth_at: Time.now.utc,
                            active: true,
                            api_token_id: apitoken.id,
                            user_id: user.id)
      rescue RuntimeError => e
        @logger.debug e.to_s
        authsession.update!(active: false)
      end

      def request_user_data
        loop do
          appshell.controller.answer.send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:"
          user_login = appshell.request_data(:login)
          appshell.controller.answer.send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
          user_password = appshell.request_data(:password)
          break [user_login, user_password] if [user_login, user_password].any?(nil) || [user_login, user_password].all?(String)
        end
      end

      def create_attributes(params, source_hash)
        return {} if params.empty?

        attributes = {}
        params.each { |param| attributes.merge!(param => source_hash[param.to_s]) }
        attributes
      end
    end
  end
end
