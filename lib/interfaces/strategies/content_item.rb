# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class ContentItem < Teachbase::Bot::Interfaces::Core
        def content(params = {})
          self.class::Content.new(params, @entity)
        end
      end
    end
  end
end
