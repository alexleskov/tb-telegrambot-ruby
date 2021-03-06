# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      attr_reader :apitoken,
                  :authsession,
                  :user,
                  :login,
                  :login_type,
                  :crypted_password,
                  :account

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @tg_user = appshell.controller.context.tg_user
      end

      def call_authsession(access_mode)
        if access_mode == :without_api
          authsession?
          @user = authsession ? authsession.user : nil
          return authsession
        end
        auth_checker unless authsession?
        @apitoken = authsession.api_token unless apitoken
        apitoken&.avaliable? ? login_by_access_token : auth_checker
        @user = authsession.user
        authsession
      end

      def unauthorize
        return unless authsession? && authsession.api_token

        authsession.api_token.update!(active: false)
        authsession.update!(active: false)
      end

      def reset_account
        return unless authsession? && authsession.account

        authsession.update!(account_id: nil)
      end

      def authsession?
        @authsession = @tg_user.auth_sessions.find_by(active: true)
      end

      def ping(client_params)
        @authsession = @tg_user.auth_sessions.find_or_create_by!(active: true)
        authsession.api_auth(:endpoint, 1, client_id: client_params[:client_id], client_secret: client_params[:client_secret],
                                           account_id: client_params[:account_id])
        authsession.ping
      rescue RestClient::Unauthorized => e
        e
      end

      def call_tb_api_endpoint_client(client_params = {})
        client_params[:client_id] ||= $app_config.client_id
        client_params[:client_secret] ||= $app_config.client_secret
        client_params[:account_id] ||= $app_config.account_id
        active_authsession_by_endpoint(client_params[:account_id])
        authsession.api_auth(:endpoint, 1, client_id: client_params[:client_id], client_secret: client_params[:client_secret],
                                           account_id: client_params[:account_id])
      end

      def registration(contact, labels = {})
        @user = Teachbase::Bot::User.find_or_create_by!(phone: contact.phone_number.to_i.to_s)
        call_tb_api_endpoint_client
        user_attrs = user_attrs_by(contact, :generate_pass)
        result = authsession.add_user_to_account(user_attrs, labels)
        user_attrs[:tb_id] = result.first["id"] unless user.tb_id
        raise "Can't add user to account" unless result

        user.update!(user_attrs)
        result
      end

      def reset_password(contact)
        @user = Teachbase::Bot::User.find_by!(phone: contact.phone_number.to_i.to_s)
        call_tb_api_endpoint_client
        raise "Don't know user's (#{user.id}) tb_id" unless user.tb_id

        user_attrs = user_attrs_by(contact, :take_new_pass)
        result = authsession.reset_user_password(user_attrs)
        raise "Password not changed" unless result.empty?

        user.update!(user_attrs)
        result
      end

      private

      def active_authsession_by_endpoint(account_id)
        @account = Teachbase::Bot::Account.find_by!(tb_id: account_id)
        raise unless account

        @authsession = @tg_user.auth_sessions.find_or_create_by!(active: true)
        authsession.update!(user_id: user.id, account_id: account.id)
      end

      def user_attrs_by(contact, password_mode = :take_new_pass)
        raise unless contact.is_a?(Teachbase::Bot::ContactController)

        password =
          if password_mode == :generate_pass
            user.password ? user.password.decrypt(:symmetric, password: $app_config.load_encrypt_key) : rand(100_000..999_999).to_s
          elsif password_mode == :take_new_pass
            taked_password = @appshell.request_user_password(:new)
            taked_password&.source
          end
        raise "Can't get password" unless password

        { first_name: contact.first_name, last_name: contact.last_name, phone: contact.phone_number.to_i.to_s,
          tb_id: user.tb_id, password: @appshell.encrypt_password(password) }
      end

      def auth_checker
        @authsession = @tg_user.auth_sessions.find_or_create_by!(active: true)
        @apitoken = authsession.api_token
        login_by_user_data unless apitoken&.avaliable?
        raise unless authsession.active?

        authsession
      end

      def login_by_user_data(client_params = {})
        client_params[:client_id] ||= $app_config.client_id
        client_params[:client_secret] ||= $app_config.client_secret
        client_params[:account_id] ||= $app_config.account_id
        take_user_auth_data
        authsession.api_auth(:mobile, 2, client_id: client_params[:client_id], client_secret: client_params[:client_secret],
                                         account_id: client_params[:account_id], user_login: login,
                                         password: crypted_password.decrypt(:symmetric, password: $app_config.load_encrypt_key))
        token = authsession.tb_api.token
        raise "Can't authorize authsession id: #{authsession.id}. User login: #{login}" unless token.value

        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id, active: true)
        apitoken.activate_by(token)

        raise "Can't find login_type: '#{login_type} for login: '#{login}'" unless login_type

        @user = Teachbase::Bot::User.find_or_create_by!(login_type => login)
        user.update!(password: crypted_password)
        authsession.activate_by(user.id, apitoken.id)
        if @appshell.user_settings.scenario == Teachbase::Bot::Strategies::DEMO_MODE_NAME
          @account = Teachbase::Bot::Account.find_by!(tb_id: client_params[:account_id])
          authsession.update!(account_id: account.id)
        end
        take_user_account_auth_data
      rescue RuntimeError => e
        $logger.debug e.to_s
        unless token&.value
          authsession&.update!(active: false)
          apitoken&.update!(active: false)
        end
        raise e
      end

      def login_by_access_token
        @account = db_user_account_auth_data
        account_id =
          if account
            account.tb_id
          elsif !account && !authsession.active
            $app_config.account_id
          elsif authsession.tb_api
            take_user_account_auth_data
            account.tb_id
          end
        authsession.api_auth(:mobile, 2, access_token: apitoken.value, account_id: account_id)
        authsession
      end

      def take_user_auth_data
        data = db_user_auth_data || @appshell.request_user_data
        raise "Can't find user auth data" if data.any?(nil)

        @login = data.first
        @crypted_password = data.second
        @login_type = kind_of_login(login)
        @login = login_type == :phone ? login.to_i.to_s : login
      end

      def take_user_account_auth_data(mode = nil)
        raise TeachbaseBotException::Account.new("Not found", 404) if Teachbase::Bot::Account.all.empty?

        data =
          if mode == :switch
            @appshell.request_user_account_data
          else
            db_user_account_auth_data || @appshell.request_user_account_data
          end
        return unless data

        @account = data.is_a?(Teachbase::Bot::Account) ? data : fetch_user_account(data)
      end

      def db_user_account_auth_data
        return unless authsession&.account

        authsession.account
      end

      def db_user_auth_data
        return unless authsession&.user

        [authsession.user.email || authsession.user.phone, authsession.user.password]
      end

      def kind_of_login(user_login)
        case user_login
        when Validator::EMAIL_MASK
          :email
        when Validator::PHONE_MASK
          :phone
        end
      end

      def fetch_user_account(data)
        user_account = Teachbase::Bot::Account.find_by(tb_id: data.to_i)
        raise TeachbaseBotException::Account.new("Access denied", 403) unless user_account

        authsession.update!(account_id: user_account.id)
        user_account
      end
    end
  end
end
