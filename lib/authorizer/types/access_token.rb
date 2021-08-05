# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class AccessToken < Teachbase::Bot::Authorizer::Base
        def build
          @access_token = @authsession.api_tokens.last_actual.value if @authsession.api_tokens&.last_actual
          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(access_token: @access_token)
        end
      end
    end
  end
end
