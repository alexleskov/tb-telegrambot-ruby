# frozen_string_literal: true

module Teachbase
  module Bot
    class ApiServer
      CATCHING_REQUEST_PARAMS = %w[HTTP_HOST REQUEST_PATH REQUEST_METHOD CONTENT_TYPE].freeze

      def call(env)
        @env = env
        webhook = match_data
        return [403, { "Content-Type" => "text/plain" }, ["Forbidden"]] unless webhook

        [200, { "Content-Type" => "text/plain" }, ["OK"]]
      rescue StandardError => e
        [500, {}, [e.message]]
      end

      def match_data
        on "/webhooks_cathcer" do
          Teachbase::Bot::Webhook::Controller.new(fetch_request_data)
        end
      end

      private

      def fetch_request_body
        payload = @env["rack.input"].read
        body = JSON.parse(payload)
      end

      def fetch_request_data
        request_data = {}
        request_data[:body] = fetch_request_body if @env["REQUEST_METHOD"] == "POST"
        @env.map do |key, value|
          request_data[key.downcase.to_sym] = value if CATCHING_REQUEST_PARAMS.include?(key.to_s)
        end
        request_data
      end

      def on(path)
        location = @env["REQUEST_PATH"].match(/^#{path}$/)
        return unless location

        location[0]
        yield
      end
    end
  end
end
