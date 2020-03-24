require './lib/authorizer'
require './lib/data_loader'

module Teachbase
  module Bot
    class AppShell
      include Formatter
      
      EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
      PHONE_MASK = /^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :access_mode, :controller, :data_loader, :settings, :authorizer, :profile, :user

      def initialize(controller, access_mode = :with_api)
        @logger = AppConfigurator.new.get_logger
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @controller = controller
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @settings = controller.respond.incoming_data.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        set_scenario
      end

      def user_info
        data_loader.call_profile #if access_mode == :with_api
        @profile = data_loader.get_user_profile
        @user = data_loader.user

        return if [profile, user].any?(nil)
      end

      def authorization(mode = nil)
        authsession = authorizer.call_authsession(mode)
        return unless authsession.is_a?(Teachbase::Bot::AuthSession)

        user_info
        authsession
      end

      def logout
        authorizer.unauthorize
      end

      def course_sessions_list(state, limit_count, offset_num)
        data_loader.call_cs_list(state) if access_mode == :with_api
        data_loader.get_cs_list(state, limit_count, offset_num)
      end

      def course_session_info(cs_id, mode = nil)
        mode ||= access_mode
        data_loader.call_cs_info(cs_id) if mode == :with_api
        data_loader.get_cs_info(cs_id)
      end

      def course_session_sections(cs_id, mode = nil)
        mode ||= access_mode
        data_loader.call_cs_sections(cs_id) if mode == :with_api
        data_loader.get_cs_sections(cs_id)
      end

      def course_session_section_contents(section_position, cs_id)
        section_bd = data_loader.get_cs_sec_by(:position, section_position, cs_id)
        return unless section_bd
        
        { section: section_bd,
          section_content: data_loader.get_cs_sec_contents(section_bd) }
      end

      def course_session_section_content(content_type, cs_tb_id, sec_id, content_tb_id)
        data_loader.call_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id) if access_mode == :with_api
        data_loader.get_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
      end

      def update_all_course_sessions
        return unless access_mode == :with_api

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

      def cs_count_by(state)
        user_info
        profile.public_send("#{state}_courses_count").to_i
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
