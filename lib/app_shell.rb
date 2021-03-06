# frozen_string_literal: true

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
        @user_settings = controller.context.settings
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
        if @current_authsession && mode != :without_api && !@current_authsession.tb_api
          @current_authsession = authorizer.call_authsession(:with_api)
        end
        @current_authsession
      end

      def user_fullname(option = :string)
        user_with_full_name.to_full_name(option)
      end

      def user_with_full_name
        user(:without_api) || controller.context.tg_user
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
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Strategies::LIST.include?(scenario_name)

        user_settings.update!(scenario: scenario_name)

        controller.context.strategy_class = controller.context.current_user_strategy_class
        controller.interface.sys_class = controller.context.current_user_interface_class
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
        # authorizer.reset_account
        account = authorizer.send(:take_user_account_auth_data, :switch)
        return unless account

        authorizer.send(:login_by_user_data,
                        client_id: authorizer.account.client_id,
                        client_secret: authorizer.account.client_secret,
                        account_id: authorizer.account.tb_id)
      end

      def request_data(answer_type)
        user_answer = controller.take_data
        return if break_taking_data?(user_answer)

        user_answer if validation(answer_type, user_answer.source)
      end

      def request_answer_bulk(params)
        loop do
          user_answer = request_data(params[:answer_type])
          break if user_answer.nil?

          user_answer.save_message(params[:saving])
          controller.interface.sys.menu(params).ready.show
        end
      end

      def request_user_data
        user_login = request_user_login
        raise "Can't find user login" unless user_login

        user_password = request_user_password
        raise "Can't find user password" unless user_password

        [user_login.source, encrypt_password(user_password.source)]
      end

      def request_user_password(state = :current)
        controller.interface.sys.text.ask_password(state).show
        request_data(:password)
      end

      def request_user_login
        controller.interface.sys.text.ask_login.show
        request_data(:login)
      end

      def request_user_account_data(avaliable_accounts = nil, options = [])
        avaliable_accounts ||= data_loader.user.accounts.avaliable_list
        raise TeachbaseBotException::Account.new("Access denied", 403) unless avaliable_accounts

        controller.interface.sys.menu.accounts(avaliable_accounts, options).show
        user_answer = controller.take_data
        controller.interface.destroy(delete_bot_message: { mode: :last })
        return unless user_answer.is_a?(CallbackController)

        user_answer.source
      rescue TeachbaseBotException => e
        if e.respond_to?(:http_code)
          case e.http_code
          when 401..403
            controller.interface.sys.text.on_forbidden.show
          when 404
            controller.interface.sys.text.error.show
          else
            raise "Unexpected error: #{e.inspect}"
          end
          nil
        end
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
        controller.context.tg_user.cache_messages.destroy_all
      end

      def cached_answers_texts
        controller.context.tg_user.cache_messages.texts
      end

      def cached_answers_files
        file_ids = controller.context.tg_user.cache_messages.files_ids
        return [] if file_ids.empty?

        file_ids
      end

      def user_cached_answer
        { text: cached_answers_texts, files: cached_answers_files }
      end

      def current_account(mode = access_mode)
        return unless authsession(mode)

        authsession(mode).account
      end

      def encrypt_password(password)
        password.encrypt(:symmetric, password: $app_config.load_encrypt_key)
      end

      private

      def break_taking_data?(msg_controller)
        return !msg_controller unless msg_controller

        result =
          case msg_controller
          when Teachbase::Bot::BotMessage
            true
          when Teachbase::Bot::TextController
            msg_controller.source =~ ABORT_ACTION_COMMAND
          when Teachbase::Bot::CommandController
            msg_controller.source
          end
        !!result
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
