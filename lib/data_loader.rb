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
      MAX_RETRIES = 5
      CS_STATES = %i[active archived].freeze
      COURSE_CONTENT_TYPES = %i[materials scorm_packages quizzes tasks].freeze

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

      def get_cs_list(state)
        get_data { user.course_sessions.order(name: :asc).where(complete_status: state.to_s,
                                                     scenario_mode: appshell.settings.scenario) }
      end

      def get_cs_sec_list(cs_id)
        get_data { get_cs_info(cs_id).sections.order(position: :asc) }
      end

      def get_cs_section_materials(cs_id, section_position)
        get_data { get_cs_sections(cs_id).materials.find_by(position: section_position) }
      end

      def call_profile
        call_data do
          lms_info = authsession.load_profile
          raise "Profile is not loaded" unless lms_info

          user_params = %i[last_name phone email avatar_url]
          profile_params = %i[active_courses_count average_score_percent archived_courses_count total_time_spent]
          profile = Teachbase::Bot::Profile.find_or_create_by!(user_id: user.id)
          user.update!(create_attributes(user_params, lms_info).merge!(tb_id: lms_info["id"], first_name: lms_info["name"]))
          profile.update!(create_attributes(profile_params, lms_info))
        end
      end

      def call_cs_list(state)
        raise "No such option for update course sessions list" unless CS_STATES.include?(state)

        call_data do
          lms_info = authsession.load_course_sessions(state)
          params = %i[name icon_url bg_url deadline listeners_count progress started_at
                      can_download success started_at can_download success full_access
                      application_status navigation rating has_certificate]
          #@logger.debug "lms_info: #{lms_info}"
          lms_info.each do |course_session|
            cs = user.course_sessions.find_by(tb_id: course_session["id"],
                                              changed_at: course_session["updated_at"])
            unless cs
              user.course_sessions.create!(create_attributes(params, course_session).merge!(tb_id: course_session["id"],
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
          return if course_last_version?(cs_id) && !course_last_version?(cs_id).sections.empty?

          course_session = user.course_sessions.find_or_create_by!(tb_id: cs_id, user_id: user.id)
          objects_params = { section: %i[name opened_at is_publish is_available],
                             materials: %i[name category],
                             scorm_packages: %i[title],
                             quizzes: %i[name],
                             tasks: %i[name] }
          authsession.load_cs_info(cs_id)["sections"].each_with_index do |section_lms, ind|
            section_bd = course_session.sections.find_or_create_by!(position: ind + 1)
            Teachbase::Bot::DataLoader::COURSE_CONTENT_TYPES.each do |type|
              custom_params = {content_type: "type"} if type == "materials"
              fetch_content(type.to_s, section_lms, section_bd, objects_params[type], custom_params || {})
            end
            section_bd.update!(create_attributes(objects_params[:section], section_lms))
          end
        end
      end

      def load_models
        @authsession = @tg_user.auth_sessions.find_by(active: true)
        auth_checker unless authsession
        @apitoken = Teachbase::Bot::ApiToken.find_by(auth_session_id: authsession.id, active: true)
        raise unless apitoken

        authsession.api_auth(:mobile_v2, access_token: apitoken.value)
        @user = authsession.user
      rescue RuntimeError
        auth_checker
        retry
      end

      def unauthorize
        authsession = Teachbase::Bot::AuthSession.find_by(tg_account_id: @tg_user.id, active: true)
        return unless authsession

        authsession.update!(active: false)
      end

      def auth_checker
        @authsession = Teachbase::Bot::AuthSession.find_or_create_by!(tg_account_id: @tg_user.id, active: true)
        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id)
        if apitoken.avaliable?
          authsession.api_auth(:mobile_v2, access_token: apitoken.value)
        else
          authsession.update!(active: false)
          login_by_user_data
        end
        @user = authsession.user
      end

      private

      def get_data
        load_models
        yield
      end

      def call_data
        load_models
        yield
      rescue RuntimeError => e
        if (@retries += 1) <= MAX_RETRIES
          appshell.controller.answer.send_out "#{I18n.t('error')} #{e}\n#{I18n.t('retry')} №#{@retries}..."
          sleep(@retries)
          retry
        else
          @logger.debug "Unexpected error after retries: #{e}"
          appshell.controller.answer.send_out "#{I18n.t('unexpected_error')}: #{e}"
        end
      end

      def course_last_version?(cs_id)
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
        buttons = appshell.controller.menu.create_inline_buttons(["signin"])
        appshell.controller.menu.create(buttons: buttons,
                                        mode: :none,
                                        type: :menu_inline,
                                        text: "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}")
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
        attributes = {}
        params.each { |param| attributes.merge!(param => source_hash[param.to_s]) }
        attributes
      end
    end
  end
end
