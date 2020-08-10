# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Text < Teachbase::Bot::InterfaceController
          def state(_state)
            answer.text.send_out(entity.sign_course_state.to_s)
          end
        end
      end
    end
  end
end
