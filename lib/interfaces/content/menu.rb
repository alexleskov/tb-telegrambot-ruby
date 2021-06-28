# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class ContentItem
        class Menu < Teachbase::Bot::Interfaces::Menu
          def content
            @type = :menu_inline
            @slices_count = 2
            @disable_notification = true
            @buttons = build_action_buttons
            @text = build_content_area
            self
          end

          protected

          def build_content_area
            ["#{create_title(object: entity.course_session, stages: %i[title], params: { cover_url: '' })} \u21B3 #{create_title(title_params)}",
             "#{Phrase.new(entity).status}\n", content_area].join("\n")
          end

          def content_area
            Phrase.empty
          end

          def build_open_button
            return unless entity.course_session.active? && open_button

            InlineUrlButton.g(button_sign: I18n.t('open').capitalize, url: to_default_protocol(entity.source))
          end

          def build_approve_button
            return unless entity.course_session.active? && entity.can_submit? && !!approve_button

            true
          end

          def build_show_answers_button
            return unless answers_avaliable? && answers_button

            InlineCallbackButton.g(button_sign: "#{I18n.t('show')} #{I18n.t('answers').downcase}",
                                   callback_data: router.g(:content, :answers, id: entity.tb_id,
                                                           p: [cs_id: entity.course_session.tb_id]).link)
          end

          def build_action_buttons
            InlineCallbackKeyboard.collect(buttons: [build_show_answers_button, build_approve_button, build_open_button], back_button: back_button).raw
          end

          def answers_avaliable?
            entity.respond_to?(:answers) && entity.answers && !entity.answers.empty?
          end
        end
      end
    end
  end
end
