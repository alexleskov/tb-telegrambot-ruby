# frozen_string_literal: true

require './models/user'
require './models/api_token'

module Teachbase
  module Bot
    class Authorizer
      attr_reader :apitoken, :authsession, :user, :login, :login_type, :crypted_password

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @logger = AppConfigurator.new.load_logger
        @appshell = appshell
        @tg_user = appshell.controller.tg_user
      end

      def call_authsession(access_mode)
        auth_checker if !authsession? && access_mode == :with_api
        @apitoken = Teachbase::Bot::ApiToken.find_by!(auth_session_id: authsession.id) unless apitoken

        if apitoken.avaliable? && authsession?
          authsession.api_auth(:mobile, 2, access_token: apitoken.value)
        else
          authsession.update!(active: false)
          auth_checker if access_mode == :with_api
        end

        @user = authsession.user
        authsession
      end

      def unauthorize
        return unless authsession?

        authsession.update!(active: false)
      end

      def authsession?
        @authsession = @tg_user.auth_sessions.find_by(active: true)
      end

      private

      def auth_checker
        @authsession = @tg_user.auth_sessions.find_or_create_by!(active: true)
        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id)

        unless apitoken.avaliable?
          authsession.update!(active: false)
          login_by_user_data
        end
        raise unless authsession.active?

        authsession
      end

      def login_by_user_data
        user_auth_data
        authsession.api_auth(:mobile, 2, user_login: login, password: crypted_password.decrypt)
        token = authsession.tb_api.token
        raise "Can't authorize authsession id: #{authsession.id}. User login: #{login}" unless token.value

        apitoken.activate_by(token)
        @user = Teachbase::Bot::User.find_or_create_by!(login_type => login)
        @user.update!(password: crypted_password)
        activate_authsession
      rescue RuntimeError => e
        @logger.debug e.to_s
        authsession.update!(active: false)
        apitoken.update!(active: false)
      end

      def activate_authsession
        authsession.update!(auth_at: Time.now.utc,
                            active: true,
                            api_token_id: apitoken.id,
                            user_id: @user.id)
      end

      def user_auth_data
        data = @appshell.request_user_data
        raise if data.any?(nil)

        @login = data.first
        @login_type = kind_of_login(login)
        @crypted_password = encrypt_password(data.second)
      end

      def encrypt_password(password)
        password.encrypt(:symmetric, password: encrypt_key)
      end

      def encrypt_key
        AppConfigurator.new.load_encrypt_key
      end

      def kind_of_login(user_login)
        case user_login
        when Validator::EMAIL_MASK
          :email
        when Validator::PHONE_MASK
          :phone
        end
      end
    end
  end
end
