# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Auth
        class Current < Teachbase::Bot::Authorizer::Auth
          def call(api_type, api_version)
            @authsession_after_auth = super(api_type, api_version, :no_save_token)
          end

          private

          def default_auth_contoller
            Teachbase::Bot::Authorizer::AccessToken.new(authsession)
          end
        end
      end
    end
  end
end