# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class UserAuthData < Teachbase::Bot::Authorizer::Base
        def initialize(authsession, appshell, account_credentials = {})
          @appshell = appshell
          super(authsession, account_credentials)
        end

        def build
          data = @authsession&.user ? @authsession.user_auth_data : @appshell.request_user_auth_data
          raise "Can't find user auth data" if data.values.any?(nil)

          @crypted_password = data[:crypted_password]
          build_login_and_type(data)
          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(user_login: login,
                       password: @crypted_password.decrypt(:symmetric, password: $app_config.load_encrypt_key))
        end
      end
    end
  end
end
