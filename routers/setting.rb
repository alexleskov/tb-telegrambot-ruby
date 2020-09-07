# frozen_string_literal: true

module Teachbase
  module Bot
    class Routers
      class Setting < Teachbase::Bot::Routers::Controller
        SOURCE = "setting"

        def edit
          [SOURCE, root_class::EDIT]
        end

        def localization
          [SOURCE, "localization"]
        end

        def scenario
          [SOURCE, "scenario"]
        end

      end
    end
  end
end