# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Base
        class Notify < Teachbase::Bot::Strategies
          TEACHSUPPORT_TG_ID = 439_802_952

          attr_reader :from_user, :type

          def initialize(controller, options)
            super(controller)
            @from_user = options[:from_user] || appshell.user_with_full_name
            @type = options[:type]
          end

          def send_to(tg_id, addit_text = "")
            interface.sys.text.ask_answer.show
            appshell.ask_answer(mode: :bulk, saving: :cache)
            appshell.authsession(:without_api) ? interface.sys.menu.after_auth.show : interface.sys.menu.starting.show
            interface.sys.menu(disable_web_page_preview: true, mode: :none).confirm_answer(:message, appshell.user_cached_answer).show
            on_answer_confirmation(reaction: user_reaction.source) do
              interface.sys.text(text: "#{build_user_message}#{addit_text}").send_to(tg_id, from_user)
            end
          end

          def to_support
            send_to(support_tg_id, "\n#{link_on_tg_user}")
          end

          def to_curator
            return interface.sys.text.on_undefined_contact.show unless curator_tg_id

            send_to(curator_tg_id)
          end

          def about(*entities_tb_id)
            appshell.authsession(:with_api)
            notifications_data = []
            entities_tb_id.flatten.each do |entity_tb_id|
              notifications_data << build_notification_data(entity_tb_id)
            end
            return if notifications_data.compact.empty?

            interface.sys.text(text: "#{default_message_about_new} #{I18n.t('studying').downcase}:\n#{notifications_data.join("\n")}").show
          end

          private

          def build_notification_data(entity_tb_id)
            entity_loader = appshell.data_loader.cs(tb_id: entity_tb_id)
            entity_loader.progress
            interface.cs(entity_loader.info).text.course.show
          rescue RestClient::NotFound => e
            nil
          end

          def build_user_message
            answer_data = build_answer_data(files_mode: :download_url)
            "#{answer_data[:text]}\n\n#{build_attachments_list(answer_data[:attachments])}"
          end

          def link_on_tg_user
            by_tg_user = appshell.controller.context.tg_user
            "<a href='tg://user?id=#{by_tg_user.id}'>#{by_tg_user.first_name} #{by_tg_user.last_name}</a>"
          end

          def default_message_about_new
            "#{default_greetings}\n\n#{I18n.t('notify_about_new')}"
          end

          def default_greetings
            "#{I18n.t('greeting_message')} #{from_user.to_full_name(:string)}!"
          end

          def support_tg_id
            if appshell.current_account(:without_api) && appshell.current_account.support_tg_id
              appshell.current_account.support_tg_id
            else
              TEACHSUPPORT_TG_ID
            end
          end

          def curator_tg_id
            return unless appshell.current_account(:without_api) && appshell.current_account.support_tg_id

            appshell.current_account.curator_tg_id
          end
        end
      end
    end
  end
end
