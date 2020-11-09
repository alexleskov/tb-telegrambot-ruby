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
        status = params[:state].to_s
        raise "No such option for update course sessions list" unless Teachbase::Bot::CourseSession::STATES.include?(status)

        mode = params[:mode] || :normal
        list_load_params = { per_page: params[:per_page], page: params[:page] }
        delete_all_by(status: status) if mode == :with_reload

        if params[:category] && params[:category] != "standart_learning"
          list_load_params[:course_types] = [Teachbase::Bot::Category.find_by_name(params[:category]).tb_id]
        end
        # TO DO: Add course category filter for lms_load if will use category filter for db entities
        lms_load(data: :listing, state: status, params: list_load_params)
        @lms_tb_ids = []
        lms_info.each do |course_lms|
          @lms_tb_ids << @tb_id = course_lms["id"].to_i
          next if course_lms["updated_at"] == db_entity.edited_at

          update_data(course_lms.merge!("status" => status))
          categories
        end
        cs_db = courses_db_with_paginate(status, params[:limit], params[:offset], params[:category])
        @db_tb_ids = cs_db.pluck(:tb_id)
        return cs_db unless delete_unsigned

        courses_db_with_paginate(status, params[:limit], params[:offset], params[:category])
      end

      def update_all_states(params = {})
        courses = {}
        mode = params[:mode] || :none
        Teachbase::Bot::CourseSession::STATES.each do |status|
          courses[status] = list(state: status, mode: mode)
        end
        courses
      end

      def total_cs_count(params)
        params[:params] ||= {}
        if params[:category] && params[:category] != "standart_learning"
          params[:params][:course_types] = [Teachbase::Bot::Category.find_by_name(params[:category]).tb_id]
        end
        lms_load(data: :total_cs_count, state: params[:state], params: params[:params])
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
        db_entity&.sections&.destroy_all
        lms_load(data: :sections)
        lms_info.each_with_index { |section_lms, ind| init_sec_loader(:position, ind + 1).update_data(section_lms) }
        db_entity.sections.order(position: :asc)
      end

      def section(option, value)
        init_sec_loader(option, value).db_entity
      end

      def model_class
        Teachbase::Bot::CourseSession
      end

      def db_entity(mode = :with_create)
        course_sessions_db = appshell.user.course_sessions
        if mode == :with_create
          course_sessions_db.find_or_create_by!(tb_id: tb_id, account_id: current_account.id)
        else
          course_sessions_db.find_by!(tb_id: tb_id, account_id: current_account.id)
        end
      end

      def cs_id
        db_entity(:no_create).id
      end

      private

      def delete_all_by(options)
        options[:account_id] = current_account.id
        appshell.user.course_sessions_by(options).destroy_all
      end

      def delete_unsigned
        unsigned_cs_tb_ids = @db_tb_ids - @lms_tb_ids
        return if unsigned_cs_tb_ids.empty?

        delete_all_by(tb_id: unsigned_cs_tb_ids)
      end

      def init_sec_loader(option, value)
        Teachbase::Bot::SectionLoader.new(appshell, option: option, value: value, cs_tb_id: tb_id)
      end

      def lms_load(options)
        options[:params] ||= {}
        options[:params].merge!(order_by: "started_at", order_direction: "desc")
        @lms_info = call_data do
          case options[:data].to_sym
          when :listing
            appshell.authsession.load_course_sessions(options[:state], options[:params])
          when :progress
            appshell.authsession.load_cs_progress(tb_id)
          when :info
            appshell.authsession.load_cs_info(tb_id)
          when :sections
            lms_load(data: :info)["sections"]
          when :total_cs_count
            options[:params][:answer_type] = :raw
            options[:params]
            appshell.authsession.load_course_sessions(options[:state], options[:params]).headers[:total].to_i
          else
            raise "Can't call such data: '#{options[:data]}'"
          end
        end
      end

      def courses_db_with_paginate(status, limit, offset, category)
        appshell.user.course_sessions_by(status: status, account_id: current_account.id, limit: limit, offset: offset,
                                         scenario: category).order(started_at: :desc)
      end

      def last_version
        appshell.user.course_sessions.find_by(tb_id: tb_id, account_id: current_account.id,
                                              edited_at: lms_load(data: :info)["updated_at"])
      end
    end
  end
end
