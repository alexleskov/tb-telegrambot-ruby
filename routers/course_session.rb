# frozen_string_literal: true

module Teachbase
  module Bot
    class Routers
      class CourseSession < Teachbase::Bot::Routers::Controller
        SOURCE = "cs"

        def sections
          entity << routers.section(path: :list).build_path
        end
      end
    end
  end
end