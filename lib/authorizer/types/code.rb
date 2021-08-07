# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Code < Teachbase::Bot::Authorizer::Base
        attr_reader :code

        def initialize(authsession, appshell, account_credentials = {})
          @appshell = appshell
          super(authsession, account_credentials)
        end

        def build
          data = @appshell.request_user_auth_code_data
          raise "Can't find user auth code data" unless data[:login] && data[:code]

          @code = data[:code]
          build_login_and_type(data)
          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(user_login: login, code: code, password: "")
        end
      end
    end
  end
end
