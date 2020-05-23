# frozen_string_literal: true

require './lib/scenarios/scenarios'
require './lib/authorizer'
require './lib/data_loader'

module Teachbase
  module Bot
    class AppShell
      include Formatter
      include Validator

      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :controller,
                  :data_loader,
                  :settings,
                  :authorizer,
                  :authsession
      attr_accessor :access_mode

      def initialize(controller, access_mode = :with_api)
        @logger = AppConfigurator.new.load_logger
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @controller = controller
        @settings = controller.respond.incoming_data.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        set_scenario
      end

      def user(_mode = access_mode)
        @authsession = authorizer.call_authsession(access_mode)
        authorizer.user
      end

      def user_info
        data_loader.call_profile
      end

      def user_fullname
        user_in_db = authorizer.authsession? ? user(:without_api) : nil
        if user_in_db && [user_in_db.first_name, user_in_db.last_name].none?(nil)
          [user_in_db.first_name, user_in_db.last_name]
        else
          controller.tg_user.user_fullname
        end
      end

      def authorization(mode = access_mode)
        user(mode)
        return unless authsession.is_a?(Teachbase::Bot::AuthSession)

        user_info
        authsession
      end

      def logout
        authorizer.unauthorize
      end

      def course_sessions_list(state, limit_count, offset_num)
        data_loader.call_cs_list(state: state, limit: limit_count, offset: offset_num)
        data_loader.get_cs_list(state: state, limit: limit_count, offset: offset_num)
      end

      def course_session_info(cs_tb_id)
        data_loader.call_cs_info(cs_tb_id)
        user.course_sessions.find_by(tb_id: cs_tb_id)
      end

      def course_session_update_progress(cs_tb_id)
        data_loader.call_cs_progress(cs_tb_id)
      end

      def course_session_section(option, param, cs_tb_id)
        data_loader.get_cs_sec_by(option, param, cs_tb_id)
      end

      def course_session_sections(cs_tb_id)
        data_loader.call_cs_sections(cs_tb_id)
        user.course_sessions.find_by(tb_id: cs_tb_id).sections.order(position: :asc)
      end

      def course_session_section_contents(section_position, cs_tb_id)
        section_bd = course_session_section(:position, section_position, cs_tb_id)
        return unless section_bd

        data_loader.call_cs_sec_contents(section_bd)
        section_bd.contents_by_types
      end

      def course_session_section_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.call_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.get_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
      end

      def course_session_task(cs_tb_id, task_tb_id)
        user.course_sessions.find_by(tb_id: cs_tb_id).tasks.find_by(tb_id: task_tb_id)
      end

      def update_all_course_sessions
        courses = {}
        Teachbase::Bot::DataLoader::CS_STATES.each do |state|
          courses[state] = data_loader.call_cs_list(state: state, mode: :with_reload)
        end
        courses
      end

      def change_scenario(scenario_name)
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Scenarios::LIST.include?(scenario_name)

        settings.update!(scenario: scenario_name)
        controller.class.send(:include, to_constantize("Teachbase::Bot::Scenarios::#{to_camelize(scenario_name)}"))
      end

      def change_localization(lang)
        settings.update!(localization: lang)
        I18n.with_locale settings.localization.to_sym do
          controller.respond.reload_commands
        end
      end

      def request_data(validate_type)
        data = take_data
        return nil if !(data =~ ABORT_ACTION_COMMAND).nil? || controller.respond.commands.command_by?(:value, data)

        data unless validation(validate_type, data).nil?
      end

      def request_user_data
        controller.answer.ask_login
        user_login = request_data(:login)
        raise unless user_login

        controller.answer.ask_password
        user_password = request_data(:password)
        [user_login, user_password]
      end

      def cs_count_by(state)
        user_info
        user.profile.public_send("#{state}_courses_count").to_i
      end

      def track_material(cs_tb_id, material_tb_id, time_spent)
        data_loader.call_track_material(cs_tb_id, material_tb_id, time_spent)
      end

      def submit_answer(cs_tb_id, task_tb_id, object_type, user_answer)
        @logger.debug "OK"
      end

      def ask_answer
        controller.answer.ask_answer
        request_data(:string)
      end

      private

      def set_scenario
        change_scenario(settings.scenario)
      end

      def take_data
        controller.respond.incoming_data.bot.listen do |message|
          msg = message.respond_to?(:text) ? message.text : message.data # for debugger
          @logger.debug "taking data: @#{message.from.username}: #{msg}"
          break message.text if message.respond_to?(:text)
        end
      end
    end
  end
end
