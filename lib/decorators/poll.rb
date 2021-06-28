# frozen_string_literal: true

module Decorators
  module Poll
    include Formatter

    def title
      "#{attach_emoji(:poll)} #{name}"
    end

    def statistics
      result = ["#{Emoji.t(:star2)}#{I18n.t('status')}: #{I18n.t("status_#{status}")}#{"\n"}", description].join("\n")
    end
  end
end
