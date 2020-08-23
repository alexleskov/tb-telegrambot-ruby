# frozen_string_literal: true

module Viewers
  module Section
    include Formatter

    def title(params)
      section_state = params ? params[:state] : :open
      emoji = attach_emoji(section_state) || Emoji.t(:open_file_folder)
      " #{emoji} #{I18n.t('section')} #{position}: #{to_bolder(name)}"
    end

    def title_with_state(state)
      section_state_msg = public_send(state) if respond_to?(state)
      "#{title(state: state)}\n#{section_state_msg}"
    end

    def open
      "<i>#{I18n.t('open')}</i>: #{back_button_action}"
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

    def back_button
      InlineCallbackButton.custom_back(back_button_action)
    end

    def back_button_action
      "/sec#{position}_cs#{course_session.tb_id}"
    end
  end
end
