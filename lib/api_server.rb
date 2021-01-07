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

          payload = @env["rack.input"].string
          JSON.parse(payload)
        end

        def account_id
          location = @env["REQUEST_PATH"].match(Teachbase::Bot::ApiServer.location_regexp)
          return unless location

          location[2].to_i
        end

        def fetch_data
          { "BODY" => body, "ACCOUNT_ID" => account_id }.compact.merge(@env.slice(*CATCHING_PARAMS))
        end
      end

      class << self
        def location_regexp(path = "\\w*")
          %r{^#{$app_config.default_location_webhooks_endpoint}\/(#{path})\/(\d*)}
        end
      end

      @catched = []

      def call(env)
        Thread.new do
          @env = env
          request = find_request_by_webhook_path
          return render(403, "403. Forbidden") unless request

          catcher = Teachbase::Bot::Webhook::Catcher.new(request)
          context = catcher.init_webhook
          @catched << body
          Teachbase::Bot::Cache.save(context, catcher.type_class)
        end
        render(200, "OK. #{@catched.join("\n")}")
      rescue StandardError => e
        render(500, e.message)
      end

      private

      def render(status, message)
        [status, {}, [message]]
      end

      def find_request_by_webhook_path
        on "webhooks_catcher" do
          Teachbase::Bot::ApiServer::Request.new(@env)
        end
      end

      def on(path)
        location = @env["REQUEST_PATH"].match(Teachbase::Bot::ApiServer.location_regexp(path))
        return unless location

        location[1]
        yield
      end
    end
  end
end
