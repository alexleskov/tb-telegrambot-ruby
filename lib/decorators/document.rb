# frozen_string_literal: true

module Decorators
  module Document
    include Formatter

    def title
      name || I18n.t('common_folder')
    end

    def sign_emoji_by_type
      is_folder ? :file_folder : :notebook_with_decorative_cover
    end
  end
end
