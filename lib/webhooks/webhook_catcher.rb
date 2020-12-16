# frozen_string_literal: true

module Teachbase
  module Bot
    class Webhook
      class Catcher
        attr_reader :webhook_type_class

        AVALIABLE_EVENT_TYPES = %w[created].freeze

        include Formatter

        def initialize(request)
          @request = request
        end

        def init_webhook
          return unless webhook_avaliable?

          find_webhook_type_class(@request.data["BODY"]["type"])
          raise unless webhook_type_class

          context = WebhookResponder.new(bot: $app_config.tg_bot_client, message: webhook_type_class.new(@request))
          strategy = context.handle
          I18n.with_locale context.settings.localization.to_sym do
            strategy.do_action
          end
        end

        private

        def webhook_avaliable?
          @request.data["BODY"] && @request.data["BODY"]["type"] && AVALIABLE_EVENT_TYPES.include?(@request.data["BODY"]["event"])
        end

        def find_webhook_type_class(webhook_type)
          @webhook_type_class = to_constantize("Teachbase::Bot::Webhook::#{to_camelize(webhook_type)}")
        end
      end
    end
  end
end
