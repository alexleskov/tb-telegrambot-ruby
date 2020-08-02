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
      when :image, :video, :audio, :pdf
        source
      when :youtube
        build_material_link_params("#{YOUTUBE_HOST}#{source}", name)
      when :iframe, :vimeo
        build_material_link_params(source, name)
      end
    end

    def title
      "#{attach_emoji(content_type.to_sym)} #{I18n.t('content').capitalize}: #{name}"
    end

    private

    def build_material_link_params(link, link_name)
      { link: link, link_name: link_name }
    end
  end
end
