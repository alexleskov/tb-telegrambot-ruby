# frozen_string_literal: true

module Decorators
  module User
    include Formatter
    PHOTO_PLACEHOLDER = "https://stickerbase.ru/wp-content/uploads/2020/02/2892.png"

    def profile_info(account_id)
      current_account_profile = current_profile(account_id)
      ["<a href='#{avatar_url}'>#{first_name} #{last_name}</a> — /u#{tb_id}",
       "ID: #{tb_id}",
       "#{I18n.t('company')}: #{current_account_profile.account.name}\n",
       "#{I18n.t('average_score_percent')}: #{current_account_profile.average_score_percent}%",
       "#{I18n.t('total_time_spent')}: #{Time.at(current_account_profile.total_time_spent).utc.strftime('%H:%M:%S')}\n",
       "#{I18n.t('courses')}:",
       "\u2022 #{I18n.t('cs_active')}: #{current_account_profile.active_courses_count}",
       "\u2022 #{I18n.t('cs_archived')}: #{current_account_profile.archived_courses_count}"].join("\n")
    end

    def photo
      avatar_url.nil? || avatar_url.empty? ? PHOTO_PLACEHOLDER : avatar_url
    end

    def link_on
      return unless tb_id

      "/u#{tb_id}"
    end
  end
end
