# frozen_string_literal: true

require './lib/authorizer/authorizer'
require './lib/data_loaders/data_loaders'

module Teachbase
  module Bot
    class AppShell
      include Formatter
      include Validator

      ABORT_ACTION_COMMAND = %r{^/stop}.freeze
      DEFAULT_ACCOUNT_NAME = "Teachbase"
      DEFAULT_ACCESS_MODE = :with_api

      attr_reader :controller,
                  :data_loader,
                  :user_settings,
                  :authorizer

      attr_accessor :access_mode

      def initialize(controller, access_mode = DEFAULT_ACCESS_MODE)
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @account_name ||= DEFAULT_ACCOUNT_NAME
        @controller = controller
        @user_settings = controller.context.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self, controller.context.tg_user)
        @data_loader = Teachbase::Bot::DataLoaders.new(self)
        set_scenario
        # set_localization
      end

      def user(mode = access_mode)
        authsession(mode)
        return unless authorizer.init_user

        authorizer.user
      end

      def authsession(mode = access_mode)
        authorizer.authsession&.tb_api ? authorizer.authsession : authorizer.init_authsession(mode)
      end

      def authorization(mode = access_mode)
        user(mode)
      end

      def logout
        authorizer.unauthorize
      end

      def change_localization(lang)
        user_settings.update!(localization: lang)
        I18n.with_locale user_settings.localization.to_sym do
          controller.reload_commands_list
        end
      end

      def change_account
        authorizer.logout_account(authsession: authsession)
        authorizer.login_account(authsession: authsession)
      end

      def change_scenario(scenario_name)
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Strategies::LIST.include?(scenario_name)

        user_settings.update!(scenario: scenario_name)

        controller.context.strategy_class = controller.context.current_user_strategy_class
        controller.interface.sys_class = controller.context.current_user_interface_class
        controller.reload_commands_list
      end

      def registration(contact, labels = {})
        raise "Expecting ContactController, given: '#{contact.class}" unless contact.is_a?(Teachbase::Bot::ContactController)

        phone_number = contact.phone_number.to_i.to_s
        new_user = Teachbase::Bot::User.find_or_create_by!(phone: phone_number)
        user_password = new_user.password ? new_user.password.decrypt(:symmetric, password: $app_config.load_encrypt_key) : rand(100_000..999_999).to_s
        user_attrs = contact.to_payload_hash
        user_attrs[:password] = user_password.to_s
        api_session = Teachbase::Bot::AuthSession.new.endpoint_v1_api
        registration_result = api_session.add_user_to_account(user_attrs, labels)
        raise "Can't add user to account" if registration_result.empty? || !registration_result

        user_attrs[:tb_id] = registration_result.first["id"] unless new_user.tb_id
        user_attrs[:password] = user_password.to_s.encrypt(:symmetric, password: $app_config.load_encrypt_key)
        new_user.update!(user_attrs)
        new_user
      end

      def reset_password(contact)
        raise "Expecting ContactController, given: '#{contact.class}" unless contact.is_a?(Teachbase::Bot::ContactController)

        phone_number = contact.phone_number.to_i.to_s
        current_user = Teachbase::Bot::User.find_by(phone: phone_number)
        raise "Don't know user with phone number: '#{phone_number}'" unless current_user

        user_password = request_user_password(:new).source
        raise "Can't get user password" unless user_password

        api_session = Teachbase::Bot::AuthSession.new.endpoint_v1_api
        reset_password_result = api_session.reset_user_password(tb_id: current_user.tb_id, password: user_password)
        raise "Password not changed" unless reset_password_result.empty?

        current_user.update!(password: user_password.to_s.encrypt(:symmetric, password: $app_config.load_encrypt_key))
        current_user
      end

      def to_default_scenario
        change_scenario(Teachbase::Bot::Strategies::STANDART_LEARNING_NAME)
      end

      def ping_account(_account_tb_id, client_params)
        Teachbase::Bot::AuthSession.new.endpoint_v1_api(client_params).ping
      rescue RestClient::Unauthorized => e
        e
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

      def request_user_auth_data
        { login: user_login,
          crypted_password: user_password.encrypt(:symmetric, password: $app_config.load_encrypt_key) }
      end

      def request_user_password(state = :current)
        controller.interface.sys.text.ask_password(state).show
        user_password = request_data(:password)
        raise "Can't find user password" unless user_password

        user_password.source
      end

      def request_user_login
        controller.interface.sys.text.ask_login.show
        user_login = request_data(:login)
        raise "Can't find user login" unless user_login

        user_login.source.downcase
      end

      def request_auth_code
        controller.interface.sys.text.ask_auth_code.show
        auth_code = request_data(:string)
        raise "Can't find auth code" unless auth_code

        auth_code.source
      end

      def request_user_account_data(avaliable_accounts = nil, options = [])
        avaliable_accounts ||= data_loader.user.accounts.avaliable_list
        raise TeachbaseBotException::Account.new("Access denied", 403) unless avaliable_accounts
        return avaliable_accounts.first.tb_id if avaliable_accounts.size == 1 && avaliable_accounts.first

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

      def user_fullname(option = :string)
        user_with_full_name.to_full_name(option)
      end

      def user_with_full_name
        user(:without_api) || controller.context.tg_user
      end

      def account_name
        return DEFAULT_ACCOUNT_NAME unless authorizer.authsession

        authsession.account && !authsession.account.name.empty? ? authsession.account.name : DEFAULT_ACCOUNT_NAME
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
