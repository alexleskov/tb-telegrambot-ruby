# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Task
        class Menu < Teachbase::Bot::Interfaces::ContentItem::Menu
          def content
            @text = [create_title(title_params), sign_entity_status, description].join("\n")
            super
          end

          def user_answers
            @type = :menu_inline
            @mode ||= :edit_msg
            @disable_web_page_preview ||= true
            @slices_count = 2
            @text = "#{create_title(title_params)}\n#{answers}"
            buttons_list = []
            buttons_list << build_comment_button
            @buttons = InlineCallbackKeyboard.collect(buttons: buttons_list, back_button: back_button).raw
            self
          end

          private

          def build_approve_button
            super
            return unless entity.course_session.active? && entity.can_submit?

            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('answer').downcase}",
                                   callback_data: router.g(:content, :take_answer, id: entity.tb_id,
                                                           p: [cs_id: cs_tb_id, answer_type: :answer]).link)
          end

          def build_comment_button
            return unless entity.can_comment?

            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('comment').downcase}",
                                   callback_data: router.g(:content, :take_answer, id: entity.tb_id,
                                                           p: [cs_id: cs_tb_id, answer_type: :comment]).link)
          end
        end
      end
    end
  end
end
