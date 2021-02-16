# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class CourseSession < Teachbase::Bot::Router::Route
        SOURCE = "cs"
        SECTIONS = "sections"

        def sections
          root + [SECTIONS]
        end
      end
    end
  end
end
