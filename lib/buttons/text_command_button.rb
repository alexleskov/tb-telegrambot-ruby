# frozen_string_literal: true

require './lib/buttons/menu_button'

class TextCommandButton < MenuButton
  class << self
    def g(options)
      super(:text_command, options)
    end
  end

  def init_button(button_sign, _type_params, _ind)
    commands.show(button_sign).to_s
  end
end
