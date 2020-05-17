# frozen_string_literal: true

module Viewers
  module Material
    include Formatter
    include Viewers::Helper

    YOUTUBE_HOST = "https://youtu.be/"

    def build_source
      case content_type.to_sym
      when :text
        text = category == "rich_text" ? source : content
        sanitize_html(text)
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

    def action_buttons(back_button = true)
      build_approve_button + build_to_section_button(back_button)
    end

    private

    def approve_button(time_spent = 50)
      cs_tb_id = course_session.tb_id
      InlineCallbackButton.g(buttons_sign: ["#{I18n.t('viewed')}"],
                             callback_data: ["approve_material_by_csid:#{cs_tb_id}_objid:#{tb_id}_time:#{time_spent}"],
                             emoji: %i[white_check_mark])
    end

    def build_approve_button
      course_session.active? ? approve_button : []
    end

    def build_to_section_button(back_button)
      back_button ? section.back_button : []
    end

    def build_material_link_params(link, link_name)
      { link: link, link_name: link_name }
    end
  end
end
