# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Text < Teachbase::Bot::InterfaceController
          def state(state)
            answer.text.send_out("#{attach_emoji(state.to_sym)} <b>#{I18n.t("courses_#{state}").capitalize}</b>")
          end
        end
      end
    end
  end
end
