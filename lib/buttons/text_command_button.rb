# frozen_string_literal: true

require './lib/buttons/button'

class TextCommandButton < Button
  ACTION_TYPE = :text_command

  class << self
    def g(options)
      super(:text_command, options)
    end
  end

  attr_reader :commands

  def initialize(type, options)
    @commands = options[:commands]
    super(type, options)
  end

  def create
    @value = commands.show(button_sign).to_s
  end
end
