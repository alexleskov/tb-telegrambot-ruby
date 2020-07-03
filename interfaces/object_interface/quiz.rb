# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Quiz
        def print_quiz(quiz)
          title = create_title(object: quiz, stages: %i[contents title])
          text = "#{title}\n#{Emoji.t(:baby)} <i>#{I18n.t('undefined_action')}</i>"
          answer.menu.custom_back(text: text,
                                  callback_data: "/sec#{quiz.section.id}_cs#{quiz.course_session.tb_id}")
        end
      end
    end
  end
end