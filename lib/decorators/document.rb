# frozen_string_literal: true

module Decorators
  module Document
    include Formatter

    FILE_EXTENSION_REGEXP = %r{\p{L}*\.(\w+$)}.freeze

    def title
      name || I18n.t('common_folder')
    end

    def sign_emoji_by_type
      is_folder ? :file_folder : :notebook_with_decorative_cover
    end

    def file_type
      result = file_name.match(FILE_EXTENSION_REGEXP)
      return unless result

      result[1]
    end
  end
end
