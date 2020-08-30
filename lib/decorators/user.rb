# frozen_string_literal: true

module Decorators
  module User
    def profile_info
      "<b>#{Emoji.t(:mortar_board)} #{I18n.t('profile_state')}</b>
      \n  <a href='#{avatar_url}'>#{first_name} #{last_name}</a>
      \n  #{Emoji.t(:school)} #{I18n.t('average_score_percent')}: #{profile.average_score_percent}%
      \n  #{Emoji.t(:hourglass)} #{I18n.t('total_time_spent')}: #{profile.total_time_spent / 3600} #{I18n.t('hour')}
      \n  #{Emoji.t(:green_book)} #{I18n.t('courses')}:
      #{I18n.t('courses_active')}: #{profile.active_courses_count}
      #{I18n.t('courses_archived')}: #{profile.archived_courses_count}"
    end
  end
end
