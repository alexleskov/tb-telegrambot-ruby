# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Task

        def print_task(task)
          buttons = task.action_buttons
          msg = attachments?(task) ? "#{task.description}\n\n#{task_attachments(task)}" : task.description
          answer.text.send_out(msg)
          menu_content_main(buttons: buttons) unless buttons.empty?
        end

        private

        def task_attachments(task)
          attachments = ["#{Emoji.t(:bookmark_tabs)} #{I18n.t("attachments").capitalize}"]
          task.attachments.each_with_index do |attach, ind|
            attachments << "#{ind + 1}. #{attach_emoji(attach.category)}#{to_url_link(attach.url, attach.name)}"
          end
          attachments.join("\n")
        end

        def attachments?(task)
          !task.attachments.empty?
        end

      end
    end
  end
end