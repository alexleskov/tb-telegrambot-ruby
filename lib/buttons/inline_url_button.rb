# frozen_string_literal: true

require './lib/buttons/button'

class InlineUrlButton < Button
  ACTION_TYPE = :url.freeze

  class << self
    def g(options)
      super(:url, options)
    end

    def to_open(url, text = "")
      g(button_sign: "#{I18n.t('open').capitalize} #{text}", url: url, emoji: :link)
    end
  end
end
