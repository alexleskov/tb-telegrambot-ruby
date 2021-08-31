# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Auth
        attr_reader :authsession, :authsession_after_auth, :oauth_controller, :auth_type

        def initialize(params = {})
          @tg_user = params[:tg_user]
          @appshell = params[:appshell]
          @authsession = params[:authsession]
          @oauth_controller = default_auth_contoller
        end

        protected

        def call(api_type, api_version, token_save_mode)
          raise "Needed authsession for calling new auth" unless authsession
          
          oauth_params = oauth_controller.build
          return unless oauth_params
          
          authsession.with_api_auth(api_type, api_version, token_save_mode.to_sym, oauth_params)
        end
      end
    end
  end
end