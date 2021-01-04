# frozen_string_literal: true

module Teachbase
  module Bot
    class Webhook
      class Catcher
        attr_reader :type_class

        AVALIABLE_EVENT_TYPES = %w[created].freeze
        MAIN_CLASS_NAME = "Teachbase::Bot::Webhook"

        include Formatter

        def initialize(request)
          @request = request
          @type_class = find_type_class(request.data["BODY"]["type"])
        end

        def init_webhook
          return unless type_class && avaliable?

          WebhookResponder.new(bot: $app_config.tg_bot_client, message: type_class.new(@request))
        end

        private

        def avaliable?
          @request.data["BODY"] && @request.data["BODY"]["type"] && AVALIABLE_EVENT_TYPES.include?(@request.data["BODY"]["event"])
        end

        def find_type_class(type)
          to_constantize("#{MAIN_CLASS_NAME}::#{to_camelize(type)}")
        end
      end
    end
  end
end
