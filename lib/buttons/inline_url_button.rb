# frozen_string_literal: true

require './lib/buttons/menu_button'

class InlineUrlButton < MenuButton
  class << self
    def g(options)
      super(:url, options)
    end

    def to_open(url, text = "")
      g(buttons_sign: ["#{I18n.t('open').capitalize} #{text}"], url: [url], emoji: [:link])
    end
  end
end
