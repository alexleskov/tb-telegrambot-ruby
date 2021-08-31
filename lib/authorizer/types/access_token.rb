# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class AccessToken < Teachbase::Bot::Authorizer::Base
        attr_reader :access_token

        def build
          return unless @authsession

          @access_token = @authsession.api_tokens.last_actual.value if @authsession.api_tokens&.last_actual
          return unless access_token

          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(access_token: access_token)
        end
      end
    end
  end
end
