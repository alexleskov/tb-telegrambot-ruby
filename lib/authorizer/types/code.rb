# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Code < Teachbase::Bot::Authorizer::Base
        attr_reader :auth_code

        def initialize(authsession, appshell, account_credentials = {})
          @appshell = appshell
          super(authsession, account_credentials)
        end

        def build
          data = { login: @authsession&.user ? @authsession.user_auth_data[:login] : @appshell.request_user_login }
          raise unless data[:login]

          data[:login] = data[:login].source if data[:login].is_a?(Teachbase::Bot::Controller)
          Teachbase::Bot::AuthSession.new.api(:no_type, 1, user_login: data[:login]).call_auth_code
          auth_code = @appshell.request_auth_code
          data[:auth_code] = auth_code.source
          raise if data.values.any?(nil)

          @auth_code = data[:auth_code]
          build_login_and_type(data)
          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(user_login: login, auth_code: auth_code, password: "")
        end
      end
    end
  end
end
