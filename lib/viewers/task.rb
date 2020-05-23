module Viewers
  module Task
    include Formatter
    include Viewers::Helper

    def title
      "#{attach_emoji(:tasks)} #{I18n.t('task').capitalize}: #{name}"
    end

    private

    def approve_button
      return [] unless can_submit?  

      cs_tb_id = course_session.tb_id
      InlineCallbackButton.g(buttons_sign: ["#{I18n.t('send')} #{I18n.t('answer').downcase}"],
                             callback_data: ["submit_tasks_by_csid:#{cs_tb_id}_objid:#{tb_id}"],
                             emoji: %i[envelope])
    end

    def can_submit?
      ["new", "declined"].include?(status)
    end

  end
end