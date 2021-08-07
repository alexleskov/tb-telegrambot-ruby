# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Auth
        class Current < Teachbase::Bot::Authorizer::Auth
          def call
            @authsession_after_auth = 
            if oauth_controller.build.values.any?(nil)
              Teachbase::Bot::Authorizer::Auth::New.new(authsession: authsession, tg_user: @tg_user, appshell: @appshell).call
            else
              super(:no_save_token)
            end
          end

          private

          def default_auth_contoller
            Teachbase::Bot::Authorizer::AccessToken.new(@appshell, authsession)
          end
        end
      end
    end
  end
end