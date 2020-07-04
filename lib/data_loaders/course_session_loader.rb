# frozen_string_literal: true

module Teachbase
  module Bot
    class CourseSessionLoader < Teachbase::Bot::DataLoaderController
      CS_STATES = %i[active archived].freeze
      CUSTOM_ATTRS = { "updated_at" => :changed_at }.freeze

      attr_reader :tb_id, :lms_info

      def initialize(appshell, params)
        @tb_id = params[:tb_id]
        super(appshell)
      end

      def list(params)
        raise "No such option for update course sessions list" unless CS_STATES.include?(params[:state].to_sym)

        mode = params[:mode] || :normal
        state = params[:state].to_s
        delete_all_by_state(state) if mode == :with_reload
        lms_load(data: :listing, state: state)
        current_index = params[:offset] || 0
        stop_index = params[:limit] ? params[:offset] + params[:limit] : lms_info.size - 1
        loop do
          @tb_id = lms_info[current_index]["id"]
          update_data(lms_info[current_index].merge!("status" => state))
          current_index += 1
          break if current_index == stop_index + 1 || lms_info[current_index].nil?
        end
        appshell.user.course_sessions_by(state: state, limit: params[:limit], offset: params[:offset],
                                         scenario: params[:scenario])
      end

      def update_all_states
        courses = {}
        CS_STATES.each do |state|
          courses[state] = data_loader.cs.list(state: state, mode: :with_reload)
        end
        courses
      end

      def info
        update_data(lms_load(data: :info))
      end

      def progress
        update_data(lms_load(data: :progress))
      end

      def sections
        call_data do
          return last_version.sections if last_version && !last_version.sections.empty?

          cs_db = db_entity
          cs_db&.sections&.destroy_all
          lms_load(data: :sections).each_with_index do |section_lms, ind|
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
            appshell.user.course_sessions.find_by(tb_id: tb_id)
          end
        end
      end

      private

      def init_sec_loader(option, value)
        Teachbase::Bot::SectionLoader.new(appshell, option: option, value: value, cs_tb_id: tb_id)
      end

      def lms_load(options)
        @lms_info = call_data do
          case options[:data].to_sym
          when :listing
            options[:params] ||= { order_by: "progress", order_direction: "asc", page: 1, per_page: 100 }
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
        appshell.user.course_sessions.find_by(tb_id: tb_id, changed_at: info.changed_at)
      end
    end
  end
end
