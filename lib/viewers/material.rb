module Viewers
  module Material
    include Formatter

    YOUTUBE_HOST = "https://youtu.be/"

    def get_content
      case content_type.to_sym
      when :text
        sanitize_html(content)
      when :image, :video, :audio, :pdf
        source
      when :youtube
        build_link_params("#{YOUTUBE_HOST}#{source}", name)
      when :iframe
        build_link_params(source, name)
      end
    end

    private

    def build_link_params(link, link_name)
      { link: link, link_name: link_name }
    end

  end
end
