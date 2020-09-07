# frozen_string_literal: true

module Decorators
  module User
    def profile_info
      "<b>#{Emoji.t(:mortar_board)} #{I18n.t('profile_state')}</b>
      \n <a href='#{avatar_url}'>#{first_name} #{last_name}</a>
      \n #{Emoji.t(:school)} #{I18n.t('average_score_percent')}: #{profile.average_score_percent}%
      #{Emoji.t(:hourglass)} #{I18n.t('total_time_spent')}: #{profile.total_time_spent / 3600} #{I18n.t('hour')}
      #{Emoji.t(:green_book)} #{I18n.t('courses')}:
      \u2022 #{I18n.t('cs_active')}: #{profile.active_courses_count}
      \u2022 #{I18n.t('cs_archived')}: #{profile.archived_courses_count}"
    end
  end
end
