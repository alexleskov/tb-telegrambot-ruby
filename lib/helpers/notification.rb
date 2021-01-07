# frozen_string_literal: true

module Teachbase
  module Bot
    module Helper
      class Notification
        attr_reader :type, :messages_by_tg_users

        def initialize(messages_by_tg_users, type)
          @type = type
          @messages_by_tg_users = messages_by_tg_users
        end

        def build
          return unless messages_by_tg_users && !messages_by_tg_users.empty?

          params = []
          messages_by_tg_users.each do |tg_user_id, messages|
            tb_ids = []
            messages.each do |message|
              tb_ids << message.body.message.public_send(id_param)
            end
            first_message = messages_by_tg_users[tg_user_id].first.body
            params << { controller: first_message.respond.init_controller, settings: first_message.settings,
                        tb_ids: tb_ids.uniq }
          end
          params
        end

        private

        def id_param
          case type
          when :cs
            :cs_tb_id
          end
        end

      end
    end
  end
end
