# frozen_string_literal: true

require './lib/buttons/inline_url_button'
require './lib/keyboards/keyboard'

class InlineUrlKeyboard < Keyboard  
  def check_building_params
    super
    raise "Expected an Array for buttons urls. You gave #{buttons_actions.class}" unless buttons_actions.is_a?(Array)
    raise "Buttons signs and buttons urls must have equal size." unless buttons_actions.size == buttons_signs.size
  end

  def button_class
    InlineUrlButton
  end
end
