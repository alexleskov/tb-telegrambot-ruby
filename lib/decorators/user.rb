# frozen_string_literal: true

module Decorators
  module User
    include Formatter

    def profile_info(account_id)
      current_account_profile = current_profile(account_id)
      ["<a href='#{avatar_url}'>#{first_name} #{last_name}</a>",
       "#{I18n.t('company')}: #{current_account_profile.account.name}",
       "ID: #{tb_id}\n",
       "#{I18n.t('average_score_percent')}: #{current_account_profile.average_score_percent}%",
       "#{I18n.t('total_time_spent')}: #{current_account_profile.total_time_spent / 3600} #{I18n.t('hour')}\n",
       "#{I18n.t('courses')}:",
       "\u2022 #{I18n.t('cs_active')}: #{current_account_profile.active_courses_count}",
       "\u2022 #{I18n.t('cs_archived')}: #{current_account_profile.archived_courses_count}"].join("\n")
    end

    def link_on
      return unless tb_id
      
      "/u#{tb_id}"
    end
  end
end
