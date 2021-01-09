# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class TgAccountMessage < ActiveRecord::Base
      has_one :tg_account

      class << self
        def raise_webhook_messages_by(params)
          raised_message_list = []
          messages_list = where("data->'payload'->>'type' = :type AND data->'payload'->>'event' = :event",
                                type: params[:type], event: params[:event]).order(created_at: :desc)
          messages_list.each do |message|
            raised_message_list << raise_message(message, Teachbase::Bot::TgAccount.find_by(id: message.tg_account_id))
          end
          { raised: raised_message_list, raw: messages_list }
        end

        private

        def raise_message(message, tg_account)
          source_name = message.file_type ? message.file_type : message.message_type
          OpenStruct.new(source_name => build_source_data(message.data, :entity), message_id: message.message_id,
                         tg_account: tg_account)
        end

        def build_source_data(data, mode)
          return data if data.is_a?(String) || mode == :plain

          OpenStruct.new(data)
        end
      end
    end
  end
end
