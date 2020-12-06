# frozen_string_literal: true

require './lib/buttons/text_command_button'
require './lib/keyboards/keyboard'

class TextCommandKeyboard < Keyboard
  def raw
    raise "Can't find keyboard value" unless value

    value.map! do |button|
      button.value
    end
  end

  def button_class
    TextCommandButton
  end
end
