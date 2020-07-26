# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Task
        class Menu < Teachbase::Bot::InterfaceController
          def show
            params.merge!(type: :menu_inline, disable_web_page_preview: true, disable_notification: true,
                          slices_count: 2, text: "#{create_title(params)}#{description}", buttons: action_buttons)
            params[:mode] ||= :none
            answer.menu.create(params)
          end

          def user_answers
            params.merge!(mode: :edit_msg, disable_web_page_preview: true, text: "#{create_title(params)}#{answers}")
            answer.menu.back(params)
          end

          private

          def build_approve_button
            return unless @params[:approve_button] && entity.can_submit? && entity.course_session.active?

            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('answer').downcase}",
                                   callback_data: "submit_task_by_csid:#{cs_tb_id}_objid:#{entity.tb_id}",
                                   emoji: :envelope)
          end
        end
      end
    end
  end
end
