# frozen_string_literal: true

module Viewers
  module Material
    include Formatter

    YOUTUBE_HOST = "https://youtu.be/"

    def build_source
      case content_type.to_sym
      when :text
        if editor_js
          to_text_by_editorjs(content)
        else
          sanitize_html(source)
        end
      when :image, :video, :audio, :pdf, :iframe, :vimeo
        to_default_protocol(source)
      when :youtube
        "#{YOUTUBE_HOST}#{source}"
      end
    end

    def title
      "#{attach_emoji(content_type.to_sym)} #{I18n.t('content').capitalize}: #{name}"
    end
  end
end