# frozen_string_literal: true

module Teachbase
  module Bot
    module Helper
      class Notification
        attr_reader :type, :messages_by_tg_users_id

        def initialize(messages_by_tg_users_id, type)
          @type = type
          @messages_by_tg_users_id = messages_by_tg_users_id
        end

        def build
          return unless messages_by_tg_users_id && !messages_by_tg_users_id.empty?

          params = []
          messages_by_tg_users_id.each do |tg_user_id, messages|
            tb_ids = []
            messages.each do |message|
              tb_ids << message.webhook.payload["data"][id_param]
            end
            first_message = messages_by_tg_users_id[tg_user_id].first
            catcher = Teachbase::Bot::Webhook::Catcher.new(first_message.webhook)
            context = catcher.init_webhook
            strategy = context.handle
            params << { controller: strategy.controller, settings: context.settings, tb_ids: tb_ids.uniq }
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
