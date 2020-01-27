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
        load_models
        user.course_sessions.find_by(tb_id: cs_id)
      end

      def get_user_profile
        load_models
        user.profile
      end

      def get_cs_list(state)
        load_models
        user.course_sessions.order(name: :asc).where(complete_status: state.to_s,
                                                     scenario_mode: appshell.settings.scenario)
      end

      def get_cs_sec_list(cs_id)
        load_models
        course_session = get_cs_info(cs_id)
        course_session.sections.order(position: :asc)
      end

      def get_cs_section_materials(cs_id, section_position)
        load_models
        get_cs_sections(cs_id).materials.find_by(position: section_position)
      end

      def call_profile
        load_models
        lms_info = authsession.load_profile
        raise "Profile is not loaded" unless lms_info

        user_params = %i[last_name phone avatar_url]
        profile_params = %i[active_courses_count average_score_percent archived_courses_count total_time_spent]
        profile = Teachbase::Bot::Profile.find_or_create_by!(user_id: user.id)
        user.update!(create_attributes(user_params, lms_info).merge!(tb_id: lms_info["id"], first_name: lms_info["name"]))
        profile.update!(create_attributes(profile_params, lms_info))
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

      def call_cs_list(state)
        raise "No such option for update course sessions list" unless CS_STATES.include?(state)

        load_models
        params = %i[name icon_url bg_url deadline listeners_count progress started_at
                    can_download success started_at can_download success full_access
                    application_status navigation rating has_certificate]

        lms_info = authsession.load_course_sessions(state)
        @logger.debug "lms_info: #{lms_info}"

        lms_info.each do |course_session|
          Teachbase::Bot::CourseSession.find_or_create_by!(user_id: user.id, tb_id: course_session["id"])
                                       .update!(create_attributes(params, course_session).merge!(complete_status: state.to_s, changed_at: course_session["updated_at"]))
        end
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

      def call_cs_sections(cs_id)
        course_session = Teachbase::Bot::CourseSession.find_by(tb_id: cs_id)
        raise "No such course_session: #{cs_id}" unless course_session

        load_models
        lms_info = authsession.load_sections(cs_id)
        sections_lms = lms_info["sections"]
        pos_index = 1
        section_params = %i[name opened_at is_publish is_available]
        material_params = %i[name category]
        scorm_params = %i[title]
        quiz_params = task_params = %i[name]

        sections_lms.each do |section_lms|
          section_bd = course_session.sections.find_or_create_by!(position: pos_index, user_id: user.id)
          fetch_content("materials", section_lms, section_bd, material_params, {content_type: "type"})
          fetch_content("scorm_packages", section_lms, section_bd, scorm_params)
          fetch_content("quizzes", section_lms, section_bd, quiz_params)
          fetch_content("tasks", section_lms, section_bd, task_params)
          section_bd.update!(create_attributes(section_params, section_lms))
          pos_index += 1
        end
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

      def load_models
        @authsession = @tg_user.auth_sessions.find_by(active: true)
        auth_checker unless authsession
        @apitoken = Teachbase::Bot::ApiToken.find_by(auth_session_id: authsession.id, active: true)
        raise unless apitoken

        authsession.api_auth(:mobile_v2, access_token: apitoken.value)
        @user = authsession.user
      end

      def unauthorize
        authsession = Teachbase::Bot::AuthSession.find_by(tg_account_id: @tg_user.id, active: true)
        raise "Nothing to unauthorize here. tg_account_id: #{@tg_user.id}" unless authsession

        authsession.update!(active: false)
      rescue RuntimeError => e
        @logger.debug e.to_s
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

      def fetch_content(conten_type, section_lms, section_bd, params, custom_params = {})
        raise "No such content type: #{conten_type}." unless section_bd.respond_to? conten_type

        lms_data = section_lms[conten_type.to_s]
        lms_data.each do |object|
          custom_data = custom_params.empty? ? {} : create_custom_params(custom_params, object)
          section_bd.public_send(conten_type)
                    .find_or_create_by!(position: object["position"], tb_id: object["id"],
                                        course_session_id: section_bd.course_session.id, user_id: user.id)
                    .update!(create_attributes(params, object).merge!(custom_data))
        end
      end

      def create_custom_params(custom_params, lms_data)
        custom_data = {}
        custom_params.each do |key, value|
          custom_data.merge!({key => lms_data[value.to_s]})
        end
        custom_data
      end

      def login_by_user_data
        user_data = request_user_data
        raise if user_data.any?(nil)

        email = user_data.first
        password = user_data.second
        crypted_password = password.encrypt(:symmetric, password: @encrypt_key)
        authsession.api_auth(:mobile_v2, user_email: email, password: crypted_password.decrypt)
        raise "Can't authorize authsession id: #{authsession.id}. Token value: #{authsession.tb_api.token.value}" unless authsession.tb_api.token.value

        apitoken.update!(version: authsession.tb_api.token.version,
                         grant_type: authsession.tb_api.token.grant_type,
                         expired_at: authsession.tb_api.token.expired_at,
                         value: authsession.tb_api.token.value,
                         active: true)
        raise "Can't load API Token" unless apitoken

        @user = Teachbase::Bot::User.find_or_create_by!(email: email)
        user.update!(password: crypted_password)
        authsession.update!(auth_at: Time.now.utc,
                            active: true,
                            api_token_id: apitoken.id,
                            user_id: user.id)
      rescue RuntimeError => e
        @logger.debug e.to_s
        authsession.update!(active: false)
        appshell.controller.answer.send_out "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
        #retry
      end

      def request_user_data
        loop do
          appshell.controller.answer.send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_email')}"
          user_email = appshell.request_data(:email)
          appshell.controller.answer.send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}"
          user_password = appshell.request_data(:password)
          break [user_email, user_password] if [user_email, user_password].any?(nil) || [user_email, user_password].all?(String)
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
