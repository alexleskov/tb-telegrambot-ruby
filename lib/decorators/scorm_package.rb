# frozen_string_literal: true

module Decorators
  module ScormPackage
    include Formatter

    def title
      "#{attach_emoji(:scorm_package)} #{name}"
    end
  end
end
