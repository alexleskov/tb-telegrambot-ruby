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

      def call_course_sessions_list(param)
        raise "No such param for update course sessions list" unless [:active, :archived].include?(param)
        auth_checker
        case param
        when :active
          course_sessions = user.load_active_course_sessions
        when :archived
          course_sessions = user.load_archived_course_sessions
        end

        course_sessions.each do |course_s|
          Teachbase::Bot::CourseSession.order(id: :asc).where(user_id: user.id, id: course_s["id"]).first_or_initialize do |bd_cs|
            bd_cs.course_name = course_s["name"]
            bd_cs.instance = course_s["name"],
            bd_cs.icon_url = course_s["icon_url"],
            bd_cs.bg_url = course_s["bg_url"],
            bd_cs.deadline = course_s["deadline"],
            bd_cs.period = course_s["period"],
            bd_cs.listeners_count = course_s["listeners_count"],
            bd_cs.progress = course_s["progress"],
            bd_cs.started_at = Time.at(course_s["started_at"]).utc,
            bd_cs.can_download = course_s["can_download"],
            bd_cs.success = course_s["success"],
            bd_cs.full_access = course_s["full_access"],
            bd_cs.application_status = course_s["application_status"],
            bd_cs.complete_status = param.to_s,
            bd_cs.id = course_s["id"]
            bd_cs.save
          end
        end
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
        auth_checker
      end

      def call_course_session_section(course_session_id)
        auth_checker
        course_session = user.load_sections(course_session_id)
        sections = course_session["sections"]
        pos_index = 1
        sections.each do |section|
          Teachbase::Bot::Section.where(course_sessions_id: course_session_id, position: pos_index).first_or_initialize do |bd_sec|
            bd_sec.part_name = section["name"]
            bd_sec.instance = section["name"]
            bd_sec.save
          end

          @logger.debug "\nSECTION: '#{section}"
          materials = section["materials"]
          materials.each do |material|
            Teachbase::Bot::Material.where(sections_id: pos_index).first_or_initialize do |bd_mat|
              bd_mat.material_name = material["name"]
              bd_mat.instance = material["name"]
              bd_mat.category = material["category"].to_i
              bd_mat.markdown = material["markdown"]
              bd_mat.id = material["id"]
              bd_mat.save
            end
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
          answer.send "#{Emoji.find_by_alias('rocket').raw}*#{I18n.t('enter')} #{I18n.t('in_teachbase')}*"
          controller.authorization
          @apitoken = Teachbase::Bot::ApiToken.find_by(user_id: user.id, active: true)
        end
      end

    end
  end
end