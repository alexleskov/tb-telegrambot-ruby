# frozen_string_literal: true

module Decorators
  module Task
    include Formatter

    def title
      "#{attach_emoji(:task)} #{name}"
    end
  end
end
