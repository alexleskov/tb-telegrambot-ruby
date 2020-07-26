# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Battle
        include Teachbase::Bot::Scenarios::Base

        def match_data
          super
        end

        def match_text_action
          super 
        end
      end
    end
  end
end
