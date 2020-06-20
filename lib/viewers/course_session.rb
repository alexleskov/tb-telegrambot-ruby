# frozen_string_literal: true

module Viewers
  module CourseSession
    include Viewers::Helper

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

    def statistics(params = {})
      params[:object] = self
      title = params[:text] || params[:stages] ? create_title(params) : ""
      "#{title}#{create_stats_msg}"
    end

    def back_button_action
      "cs_sec_by_id:#{tb_id}"
    end

    private

    def create_stats_msg
      "\n #{Emoji.t(:runner)}#{I18n.t('started_at')}: #{time_by(:started_at)}
       \n #{Emoji.t(:alarm_clock)}#{I18n.t('deadline')}: #{time_by(:deadline)}
       \n #{Emoji.t(:chart_with_upwards_trend)}#{I18n.t('progress')}: #{progress}%
       \n #{Emoji.t(:star2)}#{I18n.t('status')}: #{I18n.t("status_#{status}")}
       \n #{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{success}")}"
    end

    def sign_empty_date(option)
      option == :deadline ? "\u221e" : "-"
    end
  end
end
