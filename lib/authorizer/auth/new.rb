# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Auth
        class New < Teachbase::Bot::Authorizer::Auth
          DEFAULT_TYPE = :user_auth_data

          def initialize(params = {})
            @default_auth_type = params[:default_auth_type] || DEFAULT_TYPE
            super(params)
            @authsession = params[:authsession] || @tg_user.auth_sessions.new
          end

          def call
            authsession_with_api = super(:save_token)
            return unless authsession_with_api
            
            authsession_with_api.save!
            pop_new_user(oauth_controller.login_type, oauth_controller.login)
            @authsession_after_auth = authsession_with_api
          end

          private

          def pop_new_user(login_type, login)
            current_user = Teachbase::Bot::User.find_or_create_by!(login_type => login)
            authsession.update!(user_id: current_user.id)
            current_user
          end

          def default_auth_contoller
            case default_auth_type
            when :user_auth_data
              Teachbase::Bot::Authorizer::UserAuthData.new(@appshell, authsession)
            when :code
              Teachbase::Bot::Authorizer::Code.new(@appshell, authsession)
            else
              raise "Don't know such default_auth_type: '#{default_auth_type}'"
            end
          end
        end
      end
    end
  end
end