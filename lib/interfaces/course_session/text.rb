# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Text < Teachbase::Bot::Interfaces::Text
          def course
            @text = [text, entity.sign_open(route: router.cs(path: :entity, id: entity.tb_id).link).to_s].join("\n")
            self
          end
        end
      end
    end
  end
end
