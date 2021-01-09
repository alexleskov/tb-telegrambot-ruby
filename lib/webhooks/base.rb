# frozen_string_literal: true

module Teachbase
  module Bot
    class Webhook
      attr_accessor :tg_account
      attr_reader :webhook, :message_id

      def initialize(request)
        @webhook = request
        @message_id = Time.now.to_i
      end
    end
  end
end
