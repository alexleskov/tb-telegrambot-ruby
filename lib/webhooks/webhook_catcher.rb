# frozen_string_literal: true

module Teachbase
  module Bot
    module Webhook
      class Catcher
        AVALIABLE_EVENT_TYPES = %w[created].freeze

        include Formatter

        def initialize(request)
          @request = request
        end

        def detect_type
          return unless webhook_avaliable?

          webhook_type_class = find_webhook_type_class(@request.data["BODY"]["type"])
          raise unless webhook_type_class

          WebhookResponder.new(bot: $app_config.tg_bot_client,
                               message: webhook_type_class.new(@request)).detect_type(ai_mode: :off)
        end

        private

        def webhook_avaliable?
          @request.data["BODY"] && @request.data["BODY"]["type"] && AVALIABLE_EVENT_TYPES.include?(@request.data["BODY"]["event"])
        end

        def find_webhook_type_class(webhook_type)
          to_constantize("Teachbase::Bot::Webhook::#{to_camelize(webhook_type)}")
        end
      end
    end
  end
end
