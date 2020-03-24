require './lib/buttons/menu_button'

class TextCommandButton < MenuButton
  class << self
    def g(options)
      super(:text_command, options)
    end
  end

  def init_button(button_sign, type_params, ind)
    "#{emoji}#{commands.show(button_sign)}"
  end
end
