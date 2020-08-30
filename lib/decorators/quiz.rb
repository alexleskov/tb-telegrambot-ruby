# frozen_string_literal: true

module Decorators
  module Quiz
    include Formatter

    def title
      "#{attach_emoji(:quiz)} #{I18n.t('quiz').capitalize}: #{name}"
    end

    def statistics
      "\n#{Emoji.t(:star2)}#{I18n.t('status')}: #{I18n.t("status_#{active_status}")}
      #{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{success}")}
      #{Emoji.t(:mortar_board)}#{I18n.t(grading_method.to_s)} #{I18n.t('result').downcase}: #{to_dash_from_zero(attempt_score)} / #{total_score}
      #{Emoji.t(:runner)}#{I18n.t('attempts')}: #{available_attempts} / #{attempts}
      \n#{Emoji.t(:clipboard)}#{I18n.t('questions_count')}: #{questions_count}
      #{Emoji.t(:key)}#{I18n.t('passing_grade')}: #{to_dash_from_zero(passing_grade)}
      #{Emoji.t(:hourglass_flowing_sand)}#{I18n.t('time_limit')}: #{to_dash_from_zero(time_limit_sign)}"
    end

    def time_limit_sign
      time_limit == 0 ? time_limit : Time.at(time_limit).utc.strftime("%H:%M:%S")
    end
  end
end
