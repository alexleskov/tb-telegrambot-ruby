require './controllers/controller'
require './models/user'
require './models/api_token'

require 'encrypted_strings'

module Teachbase
  module Bot
    class DataLoader
      attr_reader :controller, :tg_user, :apitoken, :profile, :user

      def initialize(controller, param = {})
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)
        @controller = controller
        @tg_user = controller.message_responder.tg_user
        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(tg_account_id: tg_user.id, user_id: tg_user.user_id, active: true)
        @user = Teachbase::Bot::User.find_or_create_by!(tg_account_id: tg_user.id, api_token_id: apitoken.id)
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @logger = AppConfigurator.new.get_logger
      end

      def call_profile
        auth_checker
        @profile = user.load_profile

        raise "Profile is not loaded" if profile.nil?
        user.first_name = @profile["name"]
        user.last_name = @profile["last_name"]
        user.tb_id = @profile["id"]
        user.phone = @profile["phone"]
        user.save

      rescue RuntimeError => e
        @logger.debug "#{e}"
        auth_checker
      end

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
          materials.each do |material|
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

      def auth_checker
        if apitoken && apitoken.avaliable?
          user.api_auth(:mobile_v2, access_token: apitoken.value)
        else
          controller.authorization
          user.api_auth(:mobile_v2, user_email: user.email, password: user.password)
          raise "Can't authorize user id: #{user.id}. Token value: #{user.tb_api.token.value}" unless user.tb_api.token.value

          @apitoken.update!(user_id: user.id,
                            version: user.tb_api.token.version,
                            grant_type: user.tb_api.token.grant_type,
                            expired_at: user.tb_api.token.expired_at,
                            value: user.tb_api.token.value,
                            active: true)
          raise "Can't load API Token" unless @apitoken

          user.password.encrypt!(:symmetric, password: @encrypt_key)
          user.auth_at = Time.now.utc
          user.save
          tg_user.user_id = user.id
          save
        end
        rescue RuntimeError => e
          answer.send "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
          retry
      end

    private

      def create_attributes(params, source_hash)
        attributes = {}
        params.each { |param| attributes.merge!(param => source_hash[param.to_s]) }
        attributes
      end

    end
  end
end