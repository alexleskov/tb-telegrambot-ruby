#require './models/course_session'
#require './models/section'
#require './models/material'
#require './models/auth_session'
require './controllers/controller'
require './lib/data_loader'

module Teachbase
  module Bot
    class AppShell
      EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze
      BASE_SCENARIO = "Base".freeze

      attr_reader :controller, :data_loader

      def initialize(controller)
        @logger = AppConfigurator.new.get_logger
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)
        @settings = controller.respond.incoming_data.settings
        @controller = controller
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        set_scenario
        # @logger.debug "mes_res: '#{respond}"
      rescue RuntimeError => e
        controller.answer.send_out "#{I18n.t('error')} #{e}"
      end

      def authorization
        data_loader.auth_checker
        data_loader.call_profile
      end

      def logout
        data_loader.unauthorize
      end

      def profile_state
        data_loader.get_user_profile
      end

      def course_sessions_list(state)
        data_loader.call_cs_list(state)
        data_loader.get_cs_list(state)
      end

      def update_all_course_sessions_list
        Teachbase::Bot::DataLoader::CS_STATES.each do |state|
          data_loader.call_cs_list(state)
        end
      end

      def course_session_info(cs_id)
        data_loader.get_cs_info(cs_id)
      end

      def course_session_sections(cs_id)
        data_loader.call_cs_sections(cs_id)
        data_loader.get_cs_sec_list(cs_id)
      end

      def change_scenario(scenario_name)
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Scenarios::LIST.include?(scenario_name)

        @settings.update!(scenario: scenario_name)
        controller.class.send(:include, "Teachbase::Bot::Scenarios::#{scenario_name}".constantize)
      end

      def change_localization(lang)
      end

      def request_data(validate_type)
        data = take_data
        return value = nil if data =~ ABORT_ACTION_COMMAND || controller.respond.commands.command_by?(:value, data)

        value = data if validation(validate_type, data)
      end

      private

      def set_scenario
        change_scenario(@settings.scenario)
      end

      def take_data
        controller.respond.incoming_data.bot.listen do |message|
          @logger.debug "taking data: @#{message.from.username}: #{message.text}"
          break message.text
        end
      end

      def validation(type, value)
        return unless value

        case type
        when :email
          value =~ EMAIL_MASK
        when :password
          value =~ PASSWORD_MASK
        when :string
          value.is_a?(String)
        end
      end

    end
  end
end
