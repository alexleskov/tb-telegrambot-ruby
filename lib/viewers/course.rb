module Viewers
  module Course
    def statistics
      "\n #{Emoji.t(:runner)}#{I18n.t('started_at')}: #{time_by(:started_at)}
       \n #{Emoji.t(:alarm_clock)}#{I18n.t('deadline')}: #{time_by(:deadline)}
       \n #{Emoji.t(:chart_with_upwards_trend)}#{I18n.t('progress')}: #{progress}%
       \n #{Emoji.t(:star2)}#{I18n.t('complete_status')}: #{I18n.t("complete_status_#{complete_status}")}
       \n #{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{success}")}"
    end

    def time_by(param)
      raise "Can't get time by param: '#{param}" unless respond_to?(param)

      time = public_send(param)
      time.nil? ? sign_empty_date(param) : Time.parse(Time.at(time)
                                                          .strftime("%d.%m.%Y %H:%M"))
                                               .strftime("%d.%m.%Y %H:%M")
    end

    private

    def sign_empty_date(param)
      param == :deadline ? "\u221e" : "-"
    end
  end
end
