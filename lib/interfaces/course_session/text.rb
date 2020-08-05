# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Text < Teachbase::Bot::InterfaceController
          def state(state)
            answer.text.send_out("#{entity.sign_course_state}")
          end
        end
      end
    end
  end
end
