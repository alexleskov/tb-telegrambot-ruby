# frozen_string_literal: true

require './lib/authorizer/authorizer'
require './lib/authorizer/types/base'
require './lib/authorizer/types/user_auth_data'
require './lib/authorizer/types/access_token'
require './lib/authorizer/types/refresh_token'
require './lib/authorizer/types/code'
require './lib/authorizer/auth/auth'
require './lib/authorizer/auth/new'
require './lib/authorizer/auth/current'

module Teachbase
  module Bot
    class Authorizer
      attr_reader :authsession,
                  :user,
                  :tg_user

      def initialize(appshell, tg_user)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @tg_user = tg_user
      end

      def init_authsession(access_mode, params = {})
        @authsession = build_auth_session(access_mode, params)
        return unless authsession

        authsession.update!(auth_at: Time.now.utc, active: true)
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

        data = params[:account_tb_id] || @appshell.request_user_account_data
        raise "Account is not setted for authsession id: '#{params[:authsession].id}'" unless data

        user_account = Teachbase::Bot::Account.find_by(tb_id: data.to_i)
        raise TeachbaseBotException::Account.new("Access denied", 403) unless user_account

        params[:authsession].tb_api.set_account_id(data) if params[:authsession].tb_api
        params[:authsession].set_account(user_account.id)
        user_account
      end

      def logout_account(params = {})
        raise "Can't logout account without authsession" unless params[:authsession]

        params[:authsession].reset_account
      end

      private

      def build_auth_session(access_mode, params = {})
        params[:appshell] ||= @appshell
        params[:tg_user] ||= tg_user
        current_active = tg_user.auth_sessions.find_active
        return current_active if access_mode == :without_api || (current_active&.tb_api)

        result =
        if current_active && !current_active.with_api_access?
          params[:authsession] = current_active
          Teachbase::Bot::Authorizer::Auth::Current.new(params).call(:mobile, 2)
        elsif tg_user.auth_sessions.last_auth.without_logout?
          params[:authsession] = tg_user.auth_sessions.last_auth
          current_auth = Teachbase::Bot::Authorizer::Auth::Current.new(params).call(:mobile, 2)
          Teachbase::Bot::Authorizer::Auth::New.new(params.merge(auth_type: :refresh_token)).call(:mobile, 2) unless current_auth
        end
        result = Teachbase::Bot::Authorizer::Auth::New.new(params).call(:mobile, 2) unless result
        result
      end

      def force_authsession(force_user, account_tb_id = $app_config.account_id) # Worked on only user with login/password
        account_on_auth = Teachbase::Bot::Account.find_by(tb_id: account_tb_id)
        tg_user.auth_sessions.create!(auth_at: Time.now.utc, active: true, user_id: force_user.id, account_id: account_on_auth.id)
      end
    end
  end
end
