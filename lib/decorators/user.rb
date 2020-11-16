# frozen_string_literal: true

module Decorators
  module User
    include Formatter

    def profile_info(account_id)
      ["<a href='#{avatar_url}'>#{first_name} #{last_name}</a>",
       "#{I18n.t('company')}: #{auth_sessions.find_by(active: true).account.name}\n",
       "#{I18n.t('average_score_percent')}: #{current_profile(account_id).average_score_percent}%",
       "#{I18n.t('total_time_spent')}: #{current_profile(account_id).total_time_spent / 3600} #{I18n.t('hour')}\n",
       "#{I18n.t('courses')}:",
       "\u2022 #{I18n.t('cs_active')}: #{current_profile(account_id).active_courses_count}",
       "\u2022 #{I18n.t('cs_archived')}: #{current_profile(account_id).archived_courses_count}"].join("\n")
    end
  end
end
