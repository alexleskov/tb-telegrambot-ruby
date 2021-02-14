# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class Section < Teachbase::Bot::Router::Route
        SOURCE = "sec"
        ADDITIONS = "additions"

        def additions
          root + [ADDITIONS]
        end
      end
    end
  end
end
