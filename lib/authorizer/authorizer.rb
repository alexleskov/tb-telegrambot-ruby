# frozen_string_literal: true

require './lib/authorizer/authorizer'
require './lib/authorizer/types/base'
require './lib/authorizer/types/user_auth_data'
require './lib/authorizer/types/access_token'

module Teachbase
  module Bot
    class Authorizer
      DEFAULT_TYPE = :user_auth_data

      attr_reader :authsession,
                  :user,
                  :tg_user,
                  :default_auth_type

      def initialize(appshell, tg_user, default_auth_type = DEFAULT_TYPE)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @tg_user = tg_user
        @default_auth_type = default_auth_type
      end

      def init_authsession(access_mode, params = {})
        current_active = tg_user.auth_sessions.find_active
        return @authsession = current_active if access_mode == :without_api || (current_active&.tb_api)

        auth_session_after_auth =
          if current_active && !current_active.with_api_access?
            current_auth(authsession: current_active)
          elsif tg_user.auth_sessions.last_auth.without_logout?
            current_auth(authsession: tg_user.auth_sessions.last_auth)
          else
            new_auth(params)
          end
        auth_session_after_auth.update!(auth_at: Time.now.utc, active: true)
        @authsession = auth_session_after_auth
        login_account(authsession: authsession, account_tb_id: authsession.account ? authsession.account.tb_id : nil)
        authsession
      end

      def init_user
        return unless authsession&.user

        @user = authsession.user
      end

      def unauthorize
        last_session_with_auth = tg_user.auth_sessions.last_auth
        return unless last_session_with_auth&.without_logout?

        last_session_with_auth.deactivate
      end

      def login_account(params = {})
        raise TeachbaseBotException::Account.new("Not found", 404) if Teachbase::Bot::Account.all.empty?
        raise "Can't login account without authsession" unless params[:authsession]
        return if params[:authsession].account

        data = @appshell.request_user_account_data unless params[:account_tb_id]
        raise "Account is not setted for authsession id: '#{params[:authsession].id}'" unless data

        user_account = Teachbase::Bot::Account.find_by(tb_id: data.to_i)
        raise TeachbaseBotException::Account.new("Access denied", 403) unless user_account

        params[:authsession].set_account(user_account.id)
        user_account
      end

      def logout_account(params = {})
        raise "Can't logout account without authsession" unless params[:authsession]

        params[:authsession].reset_account
      end

      private

      def force_authsession(force_user, account_tb_id = $app_config.account_id)
        account_on_auth = Teachbase::Bot::Account.find_by(tb_id: account_tb_id)
        tg_user.auth_sessions.create!(auth_at: Time.now.utc, active: true, user_id: force_user.id, account_id: account_on_auth.id)
      end

      def new_auth(params = {})
        new_auth_session = params[:authsession] || tg_user.auth_sessions.new
        oauth_controller = default_auth_contoller(authsession: new_auth_session)
        auth_session_after_auth = new_auth_session.with_api_auth(:mobile, 2, :save_token, oauth_controller.build)
        raise "Can't auth tg user: '#{tg_user.id}'" unless auth_session_after_auth

        auth_session_after_auth.save!
        pop_new_user(auth_session_after_auth, oauth_controller) unless params[:authsession]
        auth_session_after_auth
      end

      def current_auth(params)
        raise "Can't find authsession for auth" unless params[:authsession]

        oauth_params = Teachbase::Bot::Authorizer::AccessToken.new(@appshell, params[:authsession]).build
        return new_auth(authsession: params[:authsession]) if oauth_params.values.any?(nil)

        auth_session_after_auth = params[:authsession].with_api_auth(:mobile, 2, :no_save_token, oauth_params)
        raise "Can't auth tg user: '#{tg_user.id}'" unless auth_session_after_auth

        auth_session_after_auth
      end

      def pop_new_user(auth_session_after_auth, oauth_controller)
        current_user = Teachbase::Bot::User.find_or_create_by!(oauth_controller.login_type => oauth_controller.login)
        auth_session_after_auth.update!(user_id: current_user.id)
        current_user
      end

      def default_auth_contoller(params = {})
        case default_auth_type
        when :user_auth_data
          Teachbase::Bot::Authorizer::UserAuthData.new(@appshell, params[:authsession])
        when :code
          Teachbase::Bot::Authorizer::Code.new(@appshell, params[:authsession])
        else
          raise "Don't know such default_auth_type: '#{default_auth_type}'"
        end
      end
    end
  end
end
