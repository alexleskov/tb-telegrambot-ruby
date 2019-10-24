require './controllers/controller'

module Teachbase
  module Bot
    class DataLoader
      attr_reader :controller, :user, :answer, :apitoken, :profile

      def initialize(controller, param = {})
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)
        @controller = controller
        @user = controller.user
        @answer = controller.answer
        @apitoken = Teachbase::Bot::ApiToken.find_by(user_id: user.id, active: true)
        @logger = AppConfigurator.new.get_logger
      end

      def call_profile
        auth_checker
        @profile = user.load_profile

        raise "Profile is not loaded" if profile.nil?
        user.first_name = @profile["name"]
        user.last_name = @profile["last_name"]
        user.external_id = @profile["id"]
        user.phone = @profile["phone"]
        user.save

      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
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

        course_sessions.each do |course_s|
          params = [:name, :icon_url, :bg_url, :deadline, :listeners_count, :progress, :started_at,
                        :can_download, :success, :started_at, :can_download, :success, :full_access,
                        :application_status]
          object_attributes = create_attributes(params, course_s).merge!(:complete_status => option.to_s)
          Teachbase::Bot::CourseSession.where(:user_id => user.id, :id => course_s["id"])
          .first_or_create!(object_attributes)
          .update!(object_attributes)
        end
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
        auth_checker
      end

      def call_course_session_section(cs_id)
        auth_checker
        course_session = user.load_sections(cs_id)
        sections = course_session["sections"]
        pos_index = 1

        sections.each do |section|
          params = [:name, :opened_at, :is_publish, :is_available]
          object_attributes = create_attributes(params, section)
          Teachbase::Bot::Section.where(:course_sessions_id => cs_id, :position => pos_index)
          .first_or_create!(object_attributes).update!(object_attributes)

          #@logger.debug "\nSECTION: '#{section}"

          materials = section["materials"]
          materials.each do |material|
            params = [:name, :category, :markdown]
            object_attributes = create_attributes(params, material)
            Teachbase::Bot::Material.where(:sections_id => pos_index, :id => material["id"])
            .first_or_create!(object_attributes).update!(object_attributes)
          end
          pos_index += 1
        end
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
        auth_checker
      end

      def auth_checker
        if apitoken && apitoken.avaliable?
          user.api_auth(:mobile_v2, access_token: apitoken.value)
        else
          answer.send "#{Emoji.find_by_alias('rocket').raw}<b>#{I18n.t('enter')} #{I18n.t('in_teachbase')}</b>"
          controller.authorization
          @apitoken = Teachbase::Bot::ApiToken.find_by(user_id: user.id, active: true)
        end
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