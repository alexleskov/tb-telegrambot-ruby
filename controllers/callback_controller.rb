# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class CallbackController < Teachbase::Bot::Controller

      def initialize(params)
        @type = "data"
        super(params, :from)
        save_message(:perm)
      end

      def source
        context.message.data
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
