# frozen_string_literal: true

module Teachbase
  module Bot
    class ApiServer
      class Request
        CATCHING_PARAMS = %w[HTTP_HOST REQUEST_PATH REQUEST_METHOD CONTENT_TYPE].freeze

        attr_reader :data

        def initialize(env)
          @env = env
          @data = fetch_data
        end

        private

        def body
          return unless @env["REQUEST_METHOD"] == "POST"

          payload = @env["rack.input"].read
          JSON.parse(payload)
        end

        def account_id
          location = @env["REQUEST_PATH"].match(/^\/(\w*)\/(\d*)/)
          return unless location

          location[2].to_i
        end

        def fetch_data
          { body: body, account_id: account_id }.compact.merge(@env.slice(*CATCHING_PARAMS))
        end
      end

      def call(env)
        @env = env
        request = init_request_by_webhook
        return render(403, "Forbidden") unless request

        Teachbase::Bot::Webhook::Controller.new(request)
        render(200, "OK")
      rescue StandardError => e
        render(500, e.message)
      end

      private

      def render(status, body)
        [status, {}, [body]]
      end

      def init_request_by_webhook
        on "/webhooks_cathcer" do
          Teachbase::Bot::ApiServer::Request.new(@env)
        end
      end

      def on(path)
        location = @env["REQUEST_PATH"].match(/^(#{path})\/(\d*)/)
        return unless location

        location[1]
        yield
      end
    end
  end
end
