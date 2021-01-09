# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class TextController < Teachbase::Bot::Controller
      def initialize(params)
        @type = "text"
        super(params, :chat)
      end

      def source
        context.message.text
      end

      def save_message(mode)
        super(mode)
      end

      def on(command, &block)
        super(command, type.to_sym, &block)
      end
    end
  end
end
