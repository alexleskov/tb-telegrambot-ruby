require './lib/buttons/menu_button'

class InlineUrlButton < MenuButton
  class << self
    def g(options)
      super(:url, options)
    end
  end
end
