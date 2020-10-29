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
            return unless params[:approve_button]
          end

          def build_show_answers_button
            return unless entity.respond_to?(:answers)
            return unless entity.answers && !entity.answers.empty? && params[:show_answers_button] && entity.course_session.active?

            InlineCallbackButton.g(button_sign: "#{I18n.t('show')} #{I18n.t('answers').downcase}",
                                   callback_data: router.content(path: :answers, id: entity.tb_id, p: [cs_id: cs_tb_id]).link)
          end

          def build_to_section_button
            return unless back_button

            InlineCallbackButton.custom_back(route_to_section)
          end

          def build_action_buttons
            @back_button ||= true
            buttons_list = [build_show_answers_button, build_approve_button, build_to_section_button]
            InlineCallbackKeyboard.collect(buttons: buttons_list).raw
          end
        end
      end
    end
  end
end
