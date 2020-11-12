# frozen_string_literal: true

module Decorators
  module Poll
    include Formatter

    def title
      "#{attach_emoji(:poll)} #{name}"
    end

    def statistics
      result = ["#{Emoji.t(:star2)}#{I18n.t('status')}: #{I18n.t("status_#{status}")}#{Formatter::DELIMETER}"]
      result << "#{I18n.t('final_message')}: #{final_message}" if show_final_message
      result.join(Formatter::DELIMETER)
    end
  end
end
