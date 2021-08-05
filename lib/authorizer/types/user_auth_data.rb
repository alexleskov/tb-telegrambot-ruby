# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class UserAuthData < Teachbase::Bot::Authorizer::Base
        attr_reader :login_type, :login

        def build
          data = @authsession&.user ? @authsession.user_auth_data : @appshell.request_user_auth_data
          raise "Can't find user auth data" if data.any?(nil)

          @crypted_password = data[:crypted_password]
          @login_type = kind_of_login(data[:login])
          @login = login_type == :phone ? data[:login].to_i.to_s : data[:login]
          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(user_login: login,
                       password: @crypted_password.decrypt(:symmetric, password: $app_config.load_encrypt_key))
        end

        def kind_of_login(login_data)
          case login_data
          when Validator::EMAIL_MASK
            :email
          when Validator::PHONE_MASK
            :phone
          end
        end
      end
    end
  end
end
