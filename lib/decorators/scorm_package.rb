# frozen_string_literal: true

module Decorators
  module ScormPackage
    include Formatter

    def title
      "#{attach_emoji(:scorm_package)} #{I18n.t('content').capitalize}: #{name}"
    end
  end
end
