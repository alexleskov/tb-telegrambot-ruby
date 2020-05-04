require './lib/scenarios'
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
                  :profile,
                  :user
      attr_accessor :access_mode

      def initialize(controller, access_mode = :with_api)
        @logger = AppConfigurator.new.get_logger
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @controller = controller
        @settings = controller.respond.incoming_data.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        set_scenario
      end

      def user_info
        data_loader.call_profile
        @profile = data_loader.get_user_profile
        @user = data_loader.user

        return if [profile, user].any?(nil)
      end

      def authorization(mode = access_mode)
        authsession = authorizer.call_authsession(mode)
        return unless authsession.is_a?(Teachbase::Bot::AuthSession)

        user_info
        authsession
      end

      def logout
        authorizer.unauthorize
      end

      def course_sessions_list(state, limit_count, offset_num)
        data_loader.call_cs_list(state)
        data_loader.get_cs_list(state, limit_count, offset_num)
      end

      def course_session_info(cs_id)
        data_loader.call_cs_info(cs_id)
        data_loader.get_cs_info(cs_id)
      end

      def course_session_sections(cs_id)
        data_loader.call_cs_sections(cs_id)
        data_loader.get_cs_sections(cs_id)
      end

      def course_session_section_contents(section_position, cs_id)
        section_bd = data_loader.get_cs_sec_by(:position, section_position, cs_id)
        return unless section_bd

        data_loader.call_cs_sec_contents(cs_id, section_position)
        { section: section_bd,
          section_content: data_loader.get_cs_sec_contents(section_bd) }
      end

      def course_session_section_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.call_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.get_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
      end

      def update_all_course_sessions
        Teachbase::Bot::DataLoader::CS_STATES.each do |state|
          data_loader.call_cs_list(state, :with_reload)
        end
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
        return value = nil if !(data =~ ABORT_ACTION_COMMAND).nil? || controller.respond.commands.command_by?(:value, data)

        value = data unless validation(validate_type, data).nil?
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
        profile.public_send("#{state}_courses_count").to_i
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
