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
          data = @appshell.request_user_auth_code_data
          return if data.values.any?(nil)

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
