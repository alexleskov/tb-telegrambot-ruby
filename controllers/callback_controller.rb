# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class CallbackController < Teachbase::Bot::Controller

      def initialize(params)
        super(params, :from)
        save_message
      end

      def source
        message.data
      end

      def save_message
        @message_params[:data] = source
        super(:perm)
      end

      def message_type
        "callback_data"
      end

      def on(command, &block)
        super(command, :data, &block)
      end
    end
  end
end
