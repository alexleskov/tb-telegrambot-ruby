# frozen_string_literal: true

require './models/user'
require './models/api_token'

module Teachbase
  module Bot
    class Authorizer
      attr_reader :apitoken, :authsession, :user, :login, :login_type, :crypted_password

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @tg_user = appshell.controller.tg_user
      end

      def call_authsession(access_mode)
        if access_mode == :without_api
          authsession?
          return @user = authsession ? authsession.user : nil
        end
        auth_checker unless authsession?
        @apitoken = authsession.api_token unless apitoken

        if apitoken&.avaliable? && authsession?
          authsession.api_auth(:mobile, 2, access_token: apitoken.value)
        else
          auth_checker
        end

        @user = authsession.user
        authsession
      end

      def unauthorize
        return unless authsession?

        authsession.api_token.update!(active: false)
        authsession.update!(active: false)
      end

      def authsession?
        @authsession = @tg_user.auth_sessions.find_by(active: true)
      end

      private

      def auth_checker
        @authsession = @tg_user.auth_sessions.find_or_create_by!(active: true)
        @apitoken = authsession.api_token
        login_by_user_data unless apitoken&.avaliable?
        raise unless authsession.active?

        authsession
      end

      def login_by_user_data
        user_auth_data
        authsession.api_auth(:mobile, 2, user_login: login,
                                         password: crypted_password.decrypt(:symmetric, password: $app_config.load_encrypt_key))
        token = authsession.tb_api.token
        raise "Can't authorize authsession id: #{authsession.id}. User login: #{login}" unless token.value

        @apitoken = Teachbase::Bot::ApiToken.find_or_create_by!(auth_session_id: authsession.id, active: true)
        apitoken.activate_by(token)
        @user = Teachbase::Bot::User.find_or_create_by!(login_type => login)
        @user.update!(password: crypted_password)
        authsession.activate_by(@user.id, apitoken.id)
      rescue RuntimeError => e
        $logger.debug e.to_s
        authsession.update!(active: false) if authsession
        apitoken.update!(active: false) if apitoken
        raise e
      end

      def user_auth_data
        data = db_user_auth_data || @appshell.request_user_data
        raise if data.any?(nil)

        @login = data.first
        @crypted_password = data.second
        kind_of_login(login)
      end

      def db_user_auth_data
        return unless authsession? && authsession.user

        [authsession.user.email || authsession.user.phone, authsession.user.password]
      end

      def kind_of_login(user_login)
        @login_type = case user_login
                      when Validator::EMAIL_MASK
                        :email
                      when Validator::PHONE_MASK
                        :phone
                      end
      end
    end
  end
end
