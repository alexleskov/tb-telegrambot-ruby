# frozen_string_literal: true

module Viewers
  module Quiz
    include Formatter

    def title
      "#{attach_emoji(:quiz)} #{I18n.t('quiz').capitalize}: #{name}"
    end
  end
end
