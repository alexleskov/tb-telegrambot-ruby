# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Object
        def initialize(answer, entity = nil)
          @answer = answer
          @entity = entity
        end

        def destroy(params)
          p "params: #{params}"
          @answer.destroy.create(params)
        end

        def text(params = {})
          self.class::Text.new(params, @answer, @entity)
        end

        def menu(params = {})
          self.class::Menu.new(params, @answer, @entity)
        end
      end
    end
  end
end
