# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class WebhookController < Teachbase::Bot::Controller
      def initialize(params)
        super(params, :tg_account)
      end

      def source
        message
      end

      def message_type
        "webhook"
      end

      def on(command, &block)
        @c_data = source
        super(command, :event_type, &block)
      end

      def find_msg_value(msg_type)
        "/webhook:#{source.public_send(msg_type)}" if source.respond_to?(msg_type)
      end
    end
  end
end
