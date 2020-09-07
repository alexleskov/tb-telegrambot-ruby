# frozen_string_literal: true

module Teachbase
  module Bot
    class CourseSessionLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = { "updated_at" => :edited_at }.freeze

      attr_reader :tb_id, :lms_info

      def initialize(appshell, params)
        @tb_id = params[:tb_id]
        super(appshell)
      end

      def list(params)
        state = params[:state].to_s
        raise "No such option for update course sessions list" unless Teachbase::Bot::CourseSession::STATES.include?(state)

        mode = params[:mode] || :normal
        delete_all_by_state(state) if mode == :with_reload
        lms_load(data: :listing, state: state)
        lms_info.each do |course_lms|
          @tb_id = course_lms["id"]
          next if course_lms["updated_at"] == db_entity.edited_at

          update_data(course_lms.merge!("status" => state))
          categories
        end
        appshell.user.course_sessions_by(state: state, limit: params[:limit], offset: params[:offset],
                                         scenario: params[:category])
      end

      def update_all_states
        courses = {}
        Teachbase::Bot::CourseSession::STATES.each do |state|
          courses[state] = appshell.data_loader.cs.list(state: state, mode: :with_reload)
        end
        courses
      end

      def info
        update_data(lms_load(data: :info))
      end

      def progress
        update_data(lms_load(data: :progress))
      end

      def categories
        Teachbase::Bot::CourseCategoryLoader.new(self).me
      end

      def sections
        call_data do
          db_entity&.sections&.destroy_all
          lms_load(data: :sections)
          lms_info.each_with_index do |section_lms, ind|
            init_sec_loader(:position, ind + 1).update_data(section_lms)
          end
        end
        db_entity.sections.order(position: :asc)
      end

      def section(option, value)
        init_sec_loader(option, value).db_entity
      end

      def delete_all_by_state(state)
        call_data { appshell.user.course_sessions.where(status: state.to_s).destroy_all }
      end

      def model_class
        Teachbase::Bot::CourseSession
      end

      def db_entity(mode = :with_create)
        call_data do
          case mode
          when :with_create
            appshell.user.course_sessions.find_or_create_by!(tb_id: tb_id)
          else
            appshell.user.course_sessions.find_by!(tb_id: tb_id)
          end
        end
      end

      def cs_id
        db_entity(:no_create).id
      end

      private

      def init_sec_loader(option, value)
        Teachbase::Bot::SectionLoader.new(appshell, option: option, value: value, cs_tb_id: tb_id)
      end

      def lms_load(options)
        @lms_info = call_data do
          case options[:data].to_sym
          when :listing
            options[:params] ||= { page: 1, per_page: 100 }
            options[:params].merge!(order_by: "started_at", order_direction: "desc")
            appshell.authsession.load_course_sessions(options[:state], options[:params])
          when :progress
            appshell.authsession.load_cs_progress(tb_id)
          when :info
            appshell.authsession.load_cs_info(tb_id)
          when :sections
            lms_load(data: :info)["sections"]
          else
            raise "Can't call such data: '#{options[:data]}'"
          end
        end
      end

      def last_version
        appshell.user.course_sessions.find_by(tb_id: tb_id, edited_at: lms_load(data: :info)["updated_at"])
      end
    end
  end
end
