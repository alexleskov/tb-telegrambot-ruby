# frozen_string_literal: true

module Teachbase
  module Bot
    class ApiServer
      @debug_info = ["Debug info history:"]
      @debug_mode = false

      class << self
        attr_accessor :debug_mode, :debug_info

        def location_regexp(path = "\\w*")
          %r{^#{$app_config.default_location_webhooks_endpoint}\/(#{path})\/(\d*)}
        end
      end

      def call(env)
        Thread.new do
          @env = env
          call_debug_mode_option
          save_input_request_payload if self.class.debug_mode
          request = find_request_by_webhook_path
          return render(403) unless request

          catcher = Teachbase::Bot::Webhook::Catcher.new(request)
          context = catcher.init_webhook
          strategy = context.handle
          strategy.controller.save_message(:perm)
        end
        render(200)
      rescue StandardError => e
        render(500, e.message)
      end

      private

      def call_debug_mode_option
        return unless @env["REQUEST_METHOD"] == "GET" && @env["REQUEST_URI"].include?("debug_mode")

        if @env["REQUEST_URI"].include?("debug_mode=on")
          self.class.debug_mode = true
        elsif @env["REQUEST_URI"].include?("debug_mode=off")
          self.class.debug_info = ["Debug info history:"]
          self.class.debug_mode = false
        elsif @env["REQUEST_URI"].include?("debug_mode=reload")
          self.class.debug_info = ["Debug info history:"]
        end
      end

      def save_input_request_payload
        return unless @env["REQUEST_METHOD"] == "POST"

        self.class.debug_info << "Time: #{Time.now}.<br>Data: #{@env['rack.input'].respond_to?(:string) ? @env['rack.input'].string : 'No payload'}"
      end

      def render(status, message = "")
        message = "Code: #{status}. #{message}"
        message = "#{message}<br>Debug mode is on." if self.class.debug_mode
        [status, { 'Content-Type' => 'text/html; charset=UTF-8' }, [message]]
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

      class Request
        CATCHING_PARAMS = %w[HTTP_HOST REQUEST_PATH REQUEST_METHOD CONTENT_TYPE].freeze

        attr_reader :payload, :account_tb_id, :http_host, :request_path, :request_method, :content_type

        def initialize(env)
          @env = env
          data = fetch_data
          @payload = data["BODY"]
          @account_tb_id = data["ACCOUNT_ID"].to_i
          @http_host = data["HTTP_HOST"]
          @request_path = data["REQUEST_PATH"]
          @request_method = data["REQUEST_METHOD"]
          @content_type = data["CONTENT_TYPE"]
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
    end
  end
end