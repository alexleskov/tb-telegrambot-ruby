# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Poll
        class Menu < Teachbase::Bot::Interfaces::ContentItem::Menu
          private

          def content_area
            entity.statistics
          end
        end
      end
    end
  end
end
