# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class WebhookController < Teachbase::Bot::Controller
      attr_reader :payload, :account_tb_id, :http_host, :request_path, :request_method, :content_type

      def initialize(params)
        @type = "event"
        super(params, :tg_account)
        @payload = source.payload
        @account_tb_id = source.account_tb_id
        @http_host = source.http_host
        @request_path = source.request_path
        @request_method = source.request_method
        @content_type = source.content_type
      end

      def source
        context.message.webhook
      end

      def on(command, &block)
        @c_data = context.message
        super(command, type.to_sym, &block)
      end

      def save_message(mode)
        return unless source

        @message_params[:message_type] = "webhook"
        @message_params[:data] = { payload: payload, account_tb_id: account_tb_id, http_host: http_host,
                                   request_path: request_path, request_method: request_method, content_type: content_type }
        super(mode)
      end

      def find_msg_value(msg_type)
        msg_type = msg_type.to_s
        "/webhook:#{payload[msg_type]}" if payload && payload[msg_type]
      end
    end
  end
end
