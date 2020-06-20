# frozen_string_literal: true

require './lib/buttons/inline_callback_button'
require './lib/keyboards/keyboard'

class InlineCallbackKeyboard < Keyboard
  class << self
    def nums(params)
      params[:buttons_signs] = give_indexes(params[:buttons_signs])
      g(params)
    end
  end
  
  def check_building_params
    super
    raise "Expected an Array for callbacks datas. You gave #{buttons_actions.class}" unless buttons_actions.is_a?(Array)
    raise "Buttons signs and buttons actions must have equal size." unless buttons_actions.size == buttons_signs.size
  end

  def button_class
    InlineCallbackButton
  end
end
