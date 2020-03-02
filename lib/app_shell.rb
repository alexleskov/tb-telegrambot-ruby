require './controllers/controller'
require './lib/authorizer'
require './lib/data_loader'

module Teachbase
  module Bot
    class AppShell
      EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
      PHONE_MASK = /^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :controller, :data_loader, :settings, :authorizer

      def initialize(controller)
        @logger = AppConfigurator.new.get_logger
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)
        @controller = controller
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @settings = controller.respond.incoming_data.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        set_scenario
        # @logger.debug "mes_res: '#{respond}"
      #rescue RuntimeError => e
      #  controller.answer.send_out "#{I18n.t('error')} #{e}"
      end

      def authorization
        authsession = authorizer.call_authsession
        return unless authsession.is_a?(Teachbase::Bot::AuthSession)

        data_loader.call_profile
      end

      def logout
        authorizer.unauthorize
      end

      def profile_state
        data_loader.get_user_profile
      end

      def course_sessions_list(state, limit_count, offset_num)
        data_loader.call_cs_list(state)
        data_loader.get_cs_list(state, limit_count, offset_num)
      end

      def course_session_info(cs_id)
        data_loader.get_cs_info(cs_id)
      end

      def course_session_sections(cs_id)
        data_loader.call_cs_sections(cs_id)
        data_loader.get_cs_sec_list(cs_id)
      end

      def course_session_section_contents(section_position, cs_id)
        section_bd = data_loader.get_cs_sec_by(:position, section_position, cs_id)
        return unless section_bd
        
        { section: section_bd,
          section_content: data_loader.get_cs_sec_content(section_bd) }
      end

      def course_session_section_open_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.call_cs_sec_open_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.get_cs_sec_content_open(content_type, cs_tb_id, sec_id, content_tb_id)
      end

      def update_all_course_sessions_list
        Teachbase::Bot::DataLoader::CS_STATES.each do |state|
          data_loader.call_cs_list(state, :with_reload)
        end
      end

      def change_scenario(scenario_name)
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Scenarios::LIST.include?(scenario_name)

        settings.update!(scenario: scenario_name)
        controller.class.send(:include, "Teachbase::Bot::Scenarios::#{to_camelize(scenario_name)}".constantize)
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
        user_data = loop do
                      controller.answer.send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:"
                      user_login = request_data(:login)
                      controller.answer.send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
                      user_password = request_data(:password)
                      break [user_login, user_password] if [user_login, user_password].any?(nil) || [user_login, user_password].all?(String)
                    end
        raise if user_data.any?(nil)

        { login: user_data.first,
          login_type: kind_of_login(user_data.first),
          crypted_password: user_data.second.encrypt(:symmetric, password: @encrypt_key) }
      end

      private

      def kind_of_login(user_login)
        case user_login
        when EMAIL_MASK
          :email
        when PHONE_MASK
          :phone
        end
      end

      def to_camelize(string)
        string.to_s.split('_').collect(&:capitalize).join
      end

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

      def validation(type, value)
        return unless value

        case type
        when :login
          value =~ EMAIL_MASK || PHONE_MASK
        when :email
          value =~ EMAIL_MASK
        when :phone
          value =~ PHONE_MASK
        when :password
          value =~ PASSWORD_MASK
        when :string
          value.is_a?(String)
        end
      end
    end
  end
end
