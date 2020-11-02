# frozen_string_literal: true

require './lib/buttons/button'

class InlineUrlButton < Button
  ACTION_TYPE = :url

  class << self
    def g(options)
      super(:url, options)
    end

    def to_open(url, text = "")
      g(button_sign: text.to_s, url: to_default_protocol(url))
    end

    private

    def to_default_protocol(url)
      url_valid?(url) ? url : url.gsub(Formatter::NOT_VAILD_URL_REGEXP, Formatter::DEFAULT_URL_PROTOCOL)
    end

    def url_valid?(url)
      url !~ Formatter::NOT_VAILD_URL_REGEXP
    end
  end
end
