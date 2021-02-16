# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class ContentItem
        class Menu < Teachbase::Bot::Interfaces::Menu
          def content
            raise "Must have ':text' param" unless text

            @type = :menu_inline
            @slices_count = 2
            @disable_notification = true
            @buttons = build_action_buttons
            @text = text.dup.insert(0, create_title(object: entity.course_session, stages: %i[title], params: { cover_url: '' }))
            self
          end

          protected

          def build_approve_button
            return unless entity.course_session.active? && approve_button
          end

          def build_show_answers_button
            return unless answers_avaliable? && answers_button

            InlineCallbackButton.g(button_sign: "#{I18n.t('show')} #{I18n.t('answers').downcase}",
                                   callback_data: router.g(:content, :answers, id: entity.tb_id, p: [cs_id: cs_tb_id]).link)
          end

          def build_action_buttons
            InlineCallbackKeyboard.collect(buttons: [build_show_answers_button, build_approve_button], back_button: back_button).raw
          end

          def answers_avaliable?
            entity.respond_to?(:answers) && entity.answers && !entity.answers.empty?
          end
        end
      end
    end
  end
end
