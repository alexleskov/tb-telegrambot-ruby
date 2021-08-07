# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Auth
        attr_reader :authsession, :authsession_after_auth, :oauth_controller, :default_auth_type

        def initialize(params = {})
          @tg_user = params[:tg_user]
          @appshell = params[:appshell]
          @authsession = params[:authsession]
          @oauth_controller = default_auth_contoller
        end

        protected

        def call(token_save_mode)
          raise "Needed authsession for calling new auth" unless authsession
          
          authsession_with_api = authsession.with_api_auth(:mobile, 2, token_save_mode.to_sym, oauth_controller.build)
          raise "Can't auth tg user: '#{@tg_user.id}'" unless authsession_with_api

          authsession_with_api
        end
      end
    end
  end
end