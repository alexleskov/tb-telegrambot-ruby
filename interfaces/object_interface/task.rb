# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Task
        def print_task(task)
          buttons = task.action_buttons(show_answers_button: true)
          title = create_title(object: task, stages: %i[contents title])
          unless buttons.empty?
            menu_content_main(buttons: buttons, mode: :edit_msg,
                              text: "#{title}#{task_description(task)}")
          end
        end

        def print_answers(task)
          title = create_title(object: task, stages: %i[contents title answers])
          answer.menu.back(text: "#{title}#{task_answers(task)}", mode: :edit_msg, disable_web_page_preview: true)
        end

        def task_description(task)
          msg = "<pre>#{task.description}</pre>\n"
          msg = "#{msg}#{object_attachments(task)}" if task.attachments?
          msg
        end

        def task_answers(task)
          answers = []
          task.answers.order(created_at: :desc).each do |answer|
            attachments = answer.attachments? ? "#{object_attachments(answer)}\n" : ""
            comments = answer.comments? ? "\n#{object_comments(answer)}\n" : ""
            answers << "<b>#{I18n.t('answer').capitalize} №#{answer.attempt}. #{I18n.t('state').capitalize}: #{attach_emoji(answer.status)} <i>#{I18n.t(answer.status).capitalize}</i></b>
                        <pre>#{answer.text}</pre>\n#{attachments}#{comments}"
          end
          answers.join("\n")
        end
      end
    end
  end
end
