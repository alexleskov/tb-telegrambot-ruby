# frozen_string_literal: true

module Teachbase
  module Bot
    class Routers
      class Content < Teachbase::Bot::Routers::Controller
        SOURCE = "ct"

        def track_time
          entity + ["track_time"]
        end

        def take_answer
          entity + ["take_answer"]
        end

        def answers
          entity + ["answers"]
        end

        def confirm_answer
          entity + ["c_answer"]
        end
      end
    end
  end
end
