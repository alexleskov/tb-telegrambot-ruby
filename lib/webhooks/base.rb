# frozen_string_literal: true

module Teachbase
  module Bot
    class Webhook
      attr_accessor :tg_account
      attr_reader :request_body, :event_type, :account_tb_id

      def initialize(request)
        @request_body = request.data["BODY"]["data"]
        @event_type = request.data["BODY"]["event"]
        @account_tb_id = request.data["ACCOUNT_ID"].to_i
      end
    end
  end
end
