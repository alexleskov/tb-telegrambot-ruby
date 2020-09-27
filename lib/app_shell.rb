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
                  :settings,
                  :authorizer

      attr_accessor :access_mode

      def initialize(controller, access_mode = :with_api)
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @account_name ||= DEFAULT_ACCOUNT_NAME
        @controller = controller
        @settings = controller.respond.msg_responder.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoaders.new(self)
        set_scenario
        # set_localization
      end

      def user(mode = access_mode)
        authsession(mode)
        authorizer.user
      end

      def authsession(mode = access_mode)
        authorizer.call_authsession(mode)
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

        controller.class.send(:include, to_constantize("Teachbase::Bot::Scenarios::#{to_camelize(scenario_name)}"))
        controller.interface.sys_class = to_constantize("Teachbase::Bot::Interfaces::#{to_camelize(scenario_name)}")
        settings.update!(scenario: scenario_name)
      end

      def change_localization(lang)
        settings.update!(localization: lang)
        I18n.with_locale settings.localization.to_sym do
          controller.respond.reload_commands
        end
      end

      def logout_account
        authorizer.reset_account
        authorizer.send(:take_user_account_auth_data)
      end

      def request_data(validate_type)
        data = controller.take_data
        return if break_taking_data?(data)

        value = data.respond_to?(:text) ? data.text : data.file
        data if validation(validate_type, value)
      end

      def request_user_data
        controller.interface.sys.text.ask_login
        user_login = request_data(:login)
        raise unless user_login

        controller.interface.sys.text.ask_password
        user_password = request_data(:password)
        raise unless user_password

        [user_login.text, encrypt_password(user_password.text)]
      end

      def request_user_account_data
        find_avaliable_accounts
        raise TeachbaseBotException::Account.new("Access denied", 403) unless @avaliable_accounts

        controller.interface.sys.menu(accounts: @avaliable_accounts).accounts
        user_answer = controller.take_data
        controller.interface.sys.destroy(delete_bot_message: :last)
        raise TeachbaseBotException::Account.new("Access denied", 403) unless user_answer.is_a?(String)

        @avaliable_accounts.select { |account| account["id"] == user_answer.to_i }.first
      end

      def find_avaliable_accounts
        accounts_by_lms = data_loader.user.accounts.lms_info
        account_ids_by_lms = accounts_by_lms.map { |account| account["id"] }
        avaliable_accounts_ids = Teachbase::Bot::Account.find_all_matches_by_tbid(account_ids_by_lms).pluck(:tb_id)
        return if avaliable_accounts_ids.empty?

        accounts = []
        avaliable_accounts_ids.each do |account_id|
          accounts << accounts_by_lms.select { |account_by_lms| account_by_lms["id"] == account_id && account_by_lms["status"] == "enabled" }.first
        end
        @avaliable_accounts = accounts.sort_by! { |account| account["name"] }
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
        result = []
        files = controller.tg_user.cache_messages.files
        return result if files.empty?

        files.each do |file_id|
          result << { file: controller.filer.upload(file_id) }
        end
        result
      end

      def user_cached_answer
        "#{cached_answers_texts}\n
         #{Emoji.t(:bookmark_tabs)} #{I18n.t('attachments').capitalize}: #{cached_answers_files.size}"
      end

      def call_tbapi(type, version)
        login = user.email? ? user.email : user.phone
        authsession.api_auth(type.to_sym, version.to_i, user_login: login,
                                                        password: user.password.decrypt(:symmetric, password: $app_config.load_encrypt_key))
      end

      private

      def encrypt_password(password)
        password.encrypt(:symmetric, password: $app_config.load_encrypt_key)
      end

      def request_answer_bulk(params)
        loop do
          user_answer = request_data(params[:answer_type])
          $logger.debug "user_answer: #{user_answer}"
          break if user_answer.nil? || (user_answer.respond_to?(:text) && break_taking_data?(user_answer.text))

          user_answer.save_message(params[:saving])
          controller.interface.sys.menu(params).ready
        end
      end

      def break_taking_data?(msg)
        if msg.respond_to?(:text)
          result = !(msg.text =~ ABORT_ACTION_COMMAND).nil? || controller.respond.commands.command_by?(:value, msg.text)
          !!result
        elsif msg.nil?
          !msg
        end
        # TO DO: Will be add something for files on else
      end

      def set_scenario
        change_scenario(settings.scenario)
      end

      #       def set_localization
      #         user_db = user(:without_api)
      #         lang = user_db && user_db.lang ? user_db.lang : settings.localization
      #         change_localization(lang)
      #       end
    end
  end
end
