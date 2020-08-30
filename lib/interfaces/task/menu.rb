# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Task
        class Menu < Teachbase::Bot::InterfaceController
          def show
            params[:text] = "#{create_title(params)}\n#{description}"
            super
          end

          def user_answers
            params.merge!(mode: :edit_msg, disable_web_page_preview: true, type: :menu_inline,
                          text: "#{create_title(params)}\n#{answers}")
            buttons = []
            buttons << build_comment_button
            params[:buttons] = InlineCallbackKeyboard.collect(buttons: buttons, back_button: params[:back_button]).raw
            answer.menu.create(params)
          end

          private

          def build_approve_button
            super
            return unless entity.course_session.active? && entity.can_submit?

            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('answer').downcase}",
                                   callback_data: "submit_task_by_csid:#{cs_tb_id}_objid:#{entity.tb_id}_w:answer",
                                   emoji: :envelope)
          end

          def build_comment_button
            return unless entity.can_comment?

            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('comment').downcase}",
                                   callback_data: "submit_task_by_csid:#{cs_tb_id}_objid:#{entity.tb_id}_w:comment",
                                   emoji: :envelope)
          end

        end
      end
    end
  end
end
