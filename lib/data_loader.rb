require './models/user'
require './models/api_token'
require './models/profile'

require 'encrypted_strings'

module Teachbase
  module Bot
    class DataLoader
      MAX_RETRIES = 5.freeze

      attr_reader :apitoken, :user, :appshell, :authsession, :profile

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)
        @appshell = appshell
        @tg_user = appshell.controller.respond.incoming_data.tg_user
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @logger = AppConfigurator.new.get_logger
      end

      def call_profile
        auth_checker
        retries = 0
        lms_info = authsession.load_profile
        raise "Profile is not loaded" unless lms_info

        @profile = Teachbase::Bot::Profile.find_or_create_by!(user_id: user.id)
        user.update!(first_name: lms_info["name"],
                     last_name: lms_info["last_name"],
                     tb_id: lms_info["id"],
                     phone: lms_info["phone"],
                     avatar_url: lms_info["avatar_url"])
        profile.update!(active_courses_count: lms_info["active_courses_count"],
                           average_score_percent: lms_info["average_score_percent"],
                           archived_courses_count: lms_info["archived_courses_count"],
                           total_time_spent: lms_info['total_time_spent'])
      rescue RuntimeError => e
        @logger.debug "#{e}"
        if (retries += 1) <= MAX_RETRIES
          appshell.controller.answer.send_out "#{I18n.t('error')} #{e}\n#{I18n.t('retry')} №#{retries}..."
          sleep(retries)
          retry
        else
          raise "Unexpected error after retries: #{e}"
          appshell.controller.answer.send_out "#{I18n.t('unexpected_error')} #{e}"
        end
      end

=begin

      def call_course_sessions_list(option)
        raise "No such option for update course sessions list" unless [:active, :archived].include?(option)
        auth_checker
        case option
        when :active
          course_sessions = user.load_active_course_sessions
        when :archived
          course_sessions = user.load_archived_course_sessions
        end
        course_s_params = [:name, :icon_url, :bg_url, :deadline, :listeners_count, :progress, :started_at,
                        :can_download, :success, :started_at, :can_download, :success, :full_access,
                        :application_status] 

        course_sessions.each do |course_s|
          object_attributes = create_attributes(course_s_params, course_s).merge!(complete_status: option.to_s)
          Teachbase::Bot::CourseSession.where(user_id: user.id, id: course_s["id"])
          .first_or_create!(object_attributes)
          .update!(object_attributes)
        end
      rescue RuntimeError => e
        @logger.debug "#{e}"
        auth_checker
      end

      def call_course_session_section(cs_id)
        auth_checker
        course_session = user.load_sections(cs_id)
        sections = course_session["sections"]
        pos_index = 1
        section_params = [:name, :opened_at, :is_publish, :is_available]
        material_params = [:name, :category, :markdown]

        sections.each do |section|
          object_attributes = create_attributes(section_params, section)
          section_bd = Teachbase::Bot::Section.where(course_session_id: cs_id, position: pos_index, user_id: user.id)
          .first_or_create!(object_attributes)
          section_bd_id = section_bd.id
          section_bd.update!(object_attributes)
          materials = section["materials"]
          materials.each do |material|crypted_passwordcrypted_password
            object_attributes = create_attributes(material_params, material)
            Teachbase::Bot::Material.where(section_id: section_bd_id, id: material["id"], course_session_id: cs_id, user_id: user.id)
            .first_or_create!(object_attributes).update!(object_attributes)
          end
          pos_index += 1
        end
      rescue RuntimeError => e
        @logger.debug "#{e}"
        auth_checker
      end

      def call_data_course_sessions
        call_course_sessions_list(:active)
        call_course_sessions_list(:archived)
      end
=end

      def auth_checker
        @authsession = Teachbase::Bot::AuthSession.find_or_create_by!(tg_account_id: @tg_user.id, active: true)
        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id)
        if apitoken.avaliable? && authsession.active
          authsession.api_auth(:mobile_v2, access_token: apitoken.value)
          @user = authsession.user
        else
          authsession.update!(active: false)
          login_by_user_data
        end
        rescue RuntimeError => e
          @logger.debug "#{e}"
          authsession.update!(active: false)
          appshell.controller.answer.send_out "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
          retry
      end

      def unauthorize
        authsession = Teachbase::Bot::AuthSession.find_by(tg_account_id: @tg_user.id, active: true)
        raise "Nothing to unauthorize here. tg_account_id: #{@tg_user.id}" unless authsession

        authsession.update!(active: false)
        rescue RuntimeError => e
          @logger.debug "#{e}"
      end

    private

      def login_by_user_data
        user_data = request_user_data
        return if user_data.any?(nil)
        
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
                            active:true,
                            api_token_id: apitoken.id,
                            user_id: user.id)
      end

      def request_user_data
        loop do
          appshell.controller.answer.send_out I18n.t('add_user_email')
          user_email = appshell.request_data(:string)
          appshell.controller.answer.send_out I18n.t('add_user_password')
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