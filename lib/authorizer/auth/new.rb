# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Auth
        class New < Teachbase::Bot::Authorizer::Auth
          DEFAULT_TYPE = :code

          def initialize(params = {})
            @auth_type = params[:auth_type] || DEFAULT_TYPE
            super(params)
            @authsession = params[:authsession] || @tg_user.auth_sessions.new
          end

          def call(api_type, api_version)
            authsession_with_api = super(api_type, api_version, :save_token)
            return unless authsession_with_api

            authsession_with_api.save!
            pop_new_user(oauth_controller.login_type, oauth_controller.login)
            @authsession_after_auth = authsession_with_api
          end

          private

          def pop_new_user(login_type, login)
            return if auth_type == :refresh_token

            current_user = Teachbase::Bot::User.find_or_create_by!(login_type => login)
            authsession.update!(user_id: current_user.id)
            current_user
          end

          def default_auth_contoller
            case auth_type
            when :user_auth_data
              Teachbase::Bot::Authorizer::UserAuthData.new(authsession, @appshell)
            when :refresh_token
              Teachbase::Bot::Authorizer::RefreshToken.new(authsession)
            when :code
              Teachbase::Bot::Authorizer::Code.new(authsession, @appshell)
            else
              raise "Don't know such auth_type: '#{auth_type}'"
            end
          end
        end
      end
    end
  end
end
