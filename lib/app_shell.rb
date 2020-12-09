# frozen_string_literal: true

require './lib/scenarios/scenarios'
require './lib/authorizer'
require './lib/data_loaders/data_loaders'

module Teachbase
  module Bot
    class AppShell
      include Formatter
      include Validator

      ABORT_ACTION_COMMAND = %r{^/stop}.freeze
      DEFAULT_ACCOUNT_NAME = "Teachbase"

      attr_reader :controller,
                  :data_loader,
                  :user_settings,
                  :authorizer

      attr_accessor :access_mode

      def initialize(controller, access_mode = :with_api)
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @account_name ||= DEFAULT_ACCOUNT_NAME
        @controller = controller
        @user_settings = controller.user_settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoaders.new(self)
        set_scenario
        # set_localization
      end

      def user(mode = access_mode)
        authsession(mode)
        @current_user ||= authorizer.user
      end

      def authsession(mode = access_mode)
        @current_authsession ||= authorizer.call_authsession(mode)
      end

      def user_fullname(option = :string)
        user_db = authorizer.authsession? ? user(:without_api) : nil
        user_name = if user_db && [user_db.first_name, user_db.last_name].none?(nil)
                      [user_db.first_name, user_db.last_name]
                    else
                      controller.tg_user.user_fullname
                    end
        option == :string ? user_name.join(" ") : user_name
      end

      def account_name
        return DEFAULT_ACCOUNT_NAME unless authorizer.authsession?

        authsession.account && !authsession.account.name.empty? ? authsession.account.name : DEFAULT_ACCOUNT_NAME
      end

      def authorization(mode = access_mode)
        user(mode)
        return unless authsession.is_a?(Teachbase::Bot::AuthSession)

        authorizer.send(:db_user_account_auth_data) unless authsession.account
        data_loader.user.me
        authsession
      end

      def logout
        authorizer.unauthorize
      end

      def change_scenario(scenario_name)
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Scenarios::LIST.include?(scenario_name)

        controller.send(:extend, to_constantize("Teachbase::Bot::Scenarios::#{to_camelize(scenario_name)}"))
        controller.interface.sys_class = to_constantize("Teachbase::Bot::Interfaces::#{to_camelize(scenario_name)}")
        user_settings.update!(scenario: scenario_name)
        controller.reload_commands_list
      end

      def reset_to_default_scenario
        change_scenario("standart_learning")
      end

      def change_localization(lang)
        user_settings.update!(localization: lang)
        I18n.with_locale user_settings.localization.to_sym do
          controller.reload_commands_list
        end
      end

      def logout_account
        authorizer.reset_account
        authorizer.send(:take_user_account_auth_data)
        authorizer.send(:login_by_user_data,
                        client_id: authorizer.account.client_id,
                        client_secret: authorizer.account.client_secret,
                        account_id: authorizer.account.tb_id)
      end

      def request_data(validate_type)
        data = controller.take_data
        return if break_taking_data?(data)

        value = if data.respond_to?(:text)
                  data.text
                elsif data.respond_to?(:file)
                  data.file
                else
                  data
                end
        data if validation(validate_type, value)
      end

      def request_user_data
        controller.interface.sys.text.ask_login.show
        user_login = request_data(:login)
        raise "Can't find user login" unless user_login

        controller.interface.sys.text.ask_password.show
        user_password = request_data(:password)
        raise "Can't find user password" unless user_password

        [user_login.text, encrypt_password(user_password.text)]
      end

=begin
      def request_user_data
        controller.interface.sys.text.ask_login.show
        user_login = request_data(:login)
        raise "Can't find user login" unless user_login

        controller.interface.sys.text.ask_password.show
        user_password = request_data(:password)
        raise "Can't find user password" unless user_password

        [user_login.text, encrypt_password(user_password.text)]
      end
=end      

      def request_user_account_data
        avaliable_accounts = data_loader.user.accounts.avaliable_list
        raise TeachbaseBotException::Account.new("Access denied", 403) unless avaliable_accounts

        controller.interface.sys.menu.accounts(avaliable_accounts).show
        user_answer = controller.take_data
        controller.interface.destroy(delete_bot_message: { mode: :last })
        raise TeachbaseBotException::Account.new("Access denied", 403) unless user_answer.is_a?(String)

        user_answer
      end

      def ask_answer(params = {})
        params[:answer_type] ||= :none
        params[:mode] ||= :once
        params[:saving] ||= :perm
        case params[:mode]
        when :once
          request_data(params[:answer_type])
        when :bulk
          request_answer_bulk(params)
        end
      end

      def clear_cached_answers
        controller.tg_user.cache_messages.destroy_all
      end

      def cached_answers_texts
        controller.tg_user.cache_messages.texts
      end

      def cached_answers_files
        file_ids = controller.tg_user.cache_messages.files_ids
        return [] if file_ids.empty?

        file_ids
      end

      def user_cached_answer
        { text: cached_answers_texts, files: cached_answers_files }
      end

      def call_tbapi(type, version)
        login = user.email? ? user.email : user.phone
        authsession.api_auth(type.to_sym, version.to_i, user_login: login,
                                                        password: user.password.decrypt(:symmetric, password: $app_config.load_encrypt_key))
      end

      def current_account(mode = access_mode)
        authsession(mode).account
      end

      def encrypt_password(password)
        password.encrypt(:symmetric, password: $app_config.load_encrypt_key)
      end

      private

      def request_answer_bulk(params)
        loop do
          user_answer = request_data(params[:answer_type])
          break if user_answer.nil?

          user_answer.save_message(params[:saving])
          controller.interface.sys.menu(params).ready.show
        end
      end

      def break_taking_data?(msg)
        if msg.respond_to?(:text)
          result = !(msg.text =~ ABORT_ACTION_COMMAND).nil? || controller.command_list.command_by?(:value, msg.text)
          !!result
        elsif msg.nil?
          !msg
        end
        # TO DO: Will be add something for files on else
      end

      def set_scenario
        change_scenario(user_settings.scenario)
      end

      #       def set_localization
      #         user_db = user(:without_api)
      #         lang = user_db && user_db.lang ? user_db.lang : user_settings.localization
      #         change_localization(lang)
      #       end
    end
  end
end
