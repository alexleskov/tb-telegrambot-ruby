# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class Content < Teachbase::Bot::Router::Route
        SOURCE = "ct"
        TRACK_TIME = "time"
        TAKE_ANSWER = "take_ans"
        ANSWERS = "anss"
        CONFIRM_ANSWER = "c_ans"

        def track_time
          root + [TRACK_TIME]
        end

        def take_answer
          root + [TAKE_ANSWER]
        end

        def answers
          root + [ANSWERS]
        end

        def confirm_answer
          root + [CONFIRM_ANSWER]
        end
      end
    end
  end
end
