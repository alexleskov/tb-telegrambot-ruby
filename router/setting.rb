# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class Setting < Teachbase::Bot::Router::Route
        SOURCE = "settings"
        LOCALIZATION = "localization"
        SCENARIO = "scenario"

        def edit
          [SOURCE, EDIT]
        end

        def localization
          [SOURCE, LOCALIZATION]
        end

        def scenario
          [SOURCE, SCENARIO]
        end
      end
    end
  end
end
