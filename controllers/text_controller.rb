# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class TextController < Teachbase::Bot::Controller
      def initialize(params)
        super(params, :chat)
      end

      def source
        message.text
      end

      def save_message(mode)
        @message_params = { text: source, message_type: "text" }
        super(mode)
      end

      def on(command, &block)
        super(command, :text, &block)
      end
    end
  end
end
