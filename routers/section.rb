# frozen_string_literal: true

module Teachbase
  module Bot
    class Routers
      class Section < Teachbase::Bot::Routers::Controller
        SOURCE = "sec"

        def list
          [SOURCE, root_class::LIST]
        end

        def additions
          entity + ["additions"]
        end
      end
    end
  end
end
