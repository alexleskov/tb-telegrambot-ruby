# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Object
        def initialize(entity)
          @entity = entity
        end

        def text(params = {})
          self.class::Text.new(params, @entity)
        end

        def menu(params = {})
          self.class::Menu.new(params, @entity)
        end

        private

        def content(params = {})
          self.class::Content.new(params, @entity)
        end
      end
    end
  end
end
