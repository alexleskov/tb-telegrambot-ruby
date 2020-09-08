# frozen_string_literal: true

module Decorators
  module Quiz
    include Formatter

    def title
      "#{attach_emoji(:quiz)} #{name}"
    end

    def statistics
      "#{I18n.t(grading_method.to_s)} #{I18n.t('result').downcase}: #{to_dash_from_zero(attempt_score)} / #{total_score}#{Formatter::DELIMETER}
       #{I18n.t('status')}: #{I18n.t("status_#{active_status}")}
       #{I18n.t('success')}: #{I18n.t("success_#{success}")}
       #{I18n.t('attempts')}: #{available_attempts} / #{attempts}#{Formatter::DELIMETER}
       #{I18n.t('questions_count')}: #{questions_count}
       #{I18n.t('passing_grade')}: #{to_dash_from_zero(passing_grade)}
       #{I18n.t('time_limit')}: #{to_dash_from_zero(time_limit_sign)}"
    end

    def time_limit_sign
      time_limit.zero? ? time_limit : Time.at(time_limit).utc.strftime("%H:%M:%S")
    end
  end
end
