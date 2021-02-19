# frozen_string_literal: true

module Teachbase
  module Bot
    module Helper
      class Notification
        attr_reader :type, :messages_by_tg_accounts_id

        def initialize(messages_by_tg_accounts_id, type)
          @type = type
          @messages_by_tg_accounts_id = messages_by_tg_accounts_id
        end

        def build
          return unless messages_by_tg_accounts_id && !messages_by_tg_accounts_id.empty?

          params = []
          messages_by_tg_accounts_id.each do |tg_account_id, messages|
            tb_ids = []
            messages.each do |message|
              tb_ids << message.webhook.payload["data"][id_param].to_i
            end
            first_message = messages_by_tg_accounts_id[tg_account_id].first
            catcher = Teachbase::Bot::Webhook::Catcher.new(first_message.webhook)
            context = catcher.init_webhook
            next unless context.tg_user

            strategy = context.handle
            params << { controller: strategy.controller, settings: context.settings, tg_account_id: tg_account_id, tb_ids: tb_ids.uniq }
          end
          params
        end

        private

        def id_param
          case type
          when :cs
            "course_session_id"
          end
        end
      end
    end
  end
end
