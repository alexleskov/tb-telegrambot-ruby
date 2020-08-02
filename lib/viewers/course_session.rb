# frozen_string_literal: true

module Viewers
  module CourseSession
    def time_by(option)
      raise "Can't get time by param: '#{option}" unless respond_to?(option)

      time = public_send(option)
      if time
        Time.parse(Time.at(time).strftime("%d.%m.%Y %H:%M")).strftime("%d.%m.%Y %H:%M")
      else
        sign_empty_date(option)
      end
    end

    def title(params)
      cover_url = params ? params[:cover_url] : icon_url
      "#{Emoji.t(:book)} <a href='#{cover_url}'>#{I18n.t('course')}</a>: #{name}"
    end

    def statistics
      "\n #{Emoji.t(:runner)}#{I18n.t('started_at')}: #{time_by(:started_at)}
       #{Emoji.t(:alarm_clock)}#{I18n.t('deadline')}: #{time_by(:deadline)}
       #{Emoji.t(:chart_with_upwards_trend)}#{I18n.t('progress')}: #{progress}%
       #{Emoji.t(:star2)}#{I18n.t('status')}: #{I18n.t("status_#{status}")}
       #{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{success}")}"
    end

    def back_button_action
      "cs_sec_by_id:#{tb_id}"
    end

    def sign_aval_sections_count_from
      "#{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
    end

    private

    def sign_empty_date(option)
      option == :deadline ? "\u221e" : "-"
    end
  end
end
