module Viewers
  module Section
    include Formatter

    def title(params)
      section_state = params ? params[:state] : :open
      emoji = attach_emoji(section_state) ? attach_emoji(section_state) : Emoji.t(:open_file_folder)
      puts "emoji: #{emoji}"
      "#{emoji} <b>#{I18n.t('section')} #{position}:</b> #{name}"
    end

    def title_with_state(state)
      section_state_msg = public_send(state) if respond_to?(state)
      "#{title(state: state)}\n#{section_state_msg}"
    end

    def open
      "<i>#{I18n.t('open')}</i>: /sec#{position}_cs#{course_session.tb_id}"
    end

    def section_unable
      "<i>#{I18n.t('section_unable')}</i>."
    end

    def section_delayed
      "<i>#{I18n.t('section_delayed')}</i>: <i>#{Time.at(opened_at).utc.strftime('%d.%m.%Y %H:%M')}.</i>"
    end

    def section_unpublish
      "<i>#{I18n.t('section_unpublish')}</i>."
    end
  end
end
