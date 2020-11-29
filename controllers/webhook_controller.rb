# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class WebhookController < Teachbase::Bot::Controller
      def initialize(params)
        super(params, :tg_account)
      end

      def on(command, &block)
        super(command, :event_type, &block)
      end
    end
  end
end
