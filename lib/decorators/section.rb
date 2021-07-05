# frozen_string_literal: true

module Decorators
  module Section
    include Formatter

    def title(params)
      section_state = params ? params[:state] : :open
      emoji = attach_emoji(section_state) || Emoji.t(:open_file_folder)
      " #{emoji} #{to_bolder(name)}"
    end

    def title_with_state(params)
      @route = params[:route]
      section_state_msg = respond_to?(params[:state]) ? public_send(params[:state]) : ""
      "#{title(params)}\n#{section_state_msg}"
    end

    def not_started
      "<i>#{I18n.t('section_delayed')}</i> <pre>#{Time.at(course_session.started_at).utc.strftime(Formatter::TIME_F)}</pre>"
    end

    def open
      "<i>#{I18n.t('open')}</i>: #{@route}"
    end

    def section_unable
      "<i>#{I18n.t('section_unable')}</i>."
    end

    def section_delayed
      "<i>#{I18n.t('section_delayed')}</i> <pre>#{Time.at(opened_at).utc.strftime(Formatter::TIME_F)}</pre>"
    end

    def section_unpublish
      "<i>#{I18n.t('section_unpublish')}</i>."
    end
  end
end
