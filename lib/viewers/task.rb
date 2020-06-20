# frozen_string_literal: true

module Viewers
  module Task
    include Formatter
    include Viewers::Helper

    def title
      "#{attach_emoji(:tasks)} #{I18n.t('task').capitalize}: #{name}"
    end

    private

    def build_approve_button
      return [] unless can_submit?

      InlineCallbackButton.g(buttons_sign: ["#{I18n.t('send')} #{I18n.t('answer').downcase}"],
                             callback_data: ["submit_task_by_csid:#{cs_tb_id}_objid:#{tb_id}"],
                             emoji: %i[envelope])
    end

    def build_show_answer_button
      InlineCallbackButton.g(buttons_sign: ["#{I18n.t('show')} #{I18n.t('answers').downcase}"],
                             callback_data: ["answers_task_by_csid:#{cs_tb_id}_objid:#{tb_id}"],
                             emoji: %i[speech_balloon])
    end
  end
end
