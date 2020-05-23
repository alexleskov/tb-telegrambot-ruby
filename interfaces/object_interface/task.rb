# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Task

        def print_task(task)
          buttons = task.action_buttons
          msg = attachments?(task) ? "#{task.description}\n\n#{task_attachments(task)}" : task.description
          answer.text.send_out(msg)
          answer.menu.task_main(buttons) unless buttons.empty?
        end

        def menu_task_main
          
        end

        private

        def task_attachments(task)
          attachments = ["#{Emoji.t(:bookmark_tabs)} #{I18n.t("attachments").capitalize}"]
          task.attachments.each do |attachment|
            attachments << to_url_link(attachment.url, attachment.name)
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