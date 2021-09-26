# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class RefreshToken < Teachbase::Bot::Authorizer::Base
        attr_reader :refresh_token

        def build
          return unless @authsession

          if @authsession.api_tokens && !@authsession.api_tokens.empty?
            @refresh_token = @authsession.api_tokens.order(created_at: :desc).first.refresh_token
          end
          return unless refresh_token

          build_oauth_params
        end

        private

        def build_oauth_params
          super.merge!(refresh_token: refresh_token)
        end
      end
    end
  end
end
