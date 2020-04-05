require './models/user'
require './models/api_token'

module Teachbase
  module Bot
    class Authorizer

      attr_reader :apitoken, :user, :authsession

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @logger = AppConfigurator.new.get_logger
        @appshell = appshell
        @tg_user = appshell.controller.respond.incoming_data.tg_user
        @encrypt_key = AppConfigurator.new.get_encrypt_key
      end

      def call_authsession(access_mode)
        mode = access_mode || @appshell.access_mode
        auth_checker unless authsession?
        @apitoken = Teachbase::Bot::ApiToken.find_by!(auth_session_id: authsession.id)
        if mode == :with_api
          unless apitoken.avaliable?
            authsession.update!(active: false)
            auth_checker
          end
          authsession.api_auth(:mobile, 2, access_token: apitoken.value)
        else
          raise unless authsession?
        end

        @user = authsession.user
        authsession
      end

      def unauthorize
        return unless authsession?

        authsession.update!(active: false)
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

      def authsession?
        @authsession = @tg_user.auth_sessions.find_by(active: true)
      end

      def login_by_user_data
        raise "You are not in ':with_api' access mode in AppShell" unless @appshell.access_mode == :with_api

        user_auth_data = @appshell.request_user_data
        raise if user_auth_data.empty?

        authsession.api_auth(:mobile, 2, user_login: user_auth_data[:login], password: user_auth_data[:crypted_password].decrypt)
        raise "Can't authorize authsession id: #{authsession.id}. User auth data: #{user_auth_data}" unless authsession.tb_api.token.value

        token = authsession.tb_api.token
        apitoken.update!(version: token.api_version,
                         api_type: token.api_type,
                         grant_type: token.grant_type,
                         expired_at: token.expired_at,
                         value: token.value,
                         active: true)
        @user = Teachbase::Bot::User.find_or_create_by!(user_auth_data[:login_type] => user_auth_data[:login])
        user.update!(password: user_auth_data[:crypted_password])
        authsession.update!(auth_at: Time.now.utc,
                            active: true,
                            api_token_id: apitoken.id,
                            user_id: user.id)
      rescue RuntimeError => e
        @logger.debug e.to_s
        authsession.update!(active: false)
        apitoken.update!(active: false)
      end

    end
  end
end