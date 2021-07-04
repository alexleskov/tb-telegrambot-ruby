# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Task
        class Menu < Teachbase::Bot::Interfaces::ContentItem::Menu
          def user_answers
            @params[:type] = :menu_inline
            @params[:mode] ||= :edit_msg
            @params[:disable_web_page_preview] ||= true
            @params[:slices_count] = 2
            @params[:text] = "#{create_title(title_params)}\n#{answers}"
            buttons_list = []
            buttons_list << build_comment_button
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: buttons_list, back_button: back_button).raw
            self
          end

          private

          alias content_area description

          def build_approve_button
            return unless super

            router_parameters = { cs_id: entity.course_session.tb_id, answer_type: :answer }
            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('answer').downcase}",
                                   callback_data: router.g(:content, :take_answer, id: entity.tb_id,
                                                                                   p: [router_parameters]).link)
          end

          def build_comment_button
            return unless entity.can_comment?

            router_parameters = { cs_id: entity.course_session.tb_id, answer_type: :comment }
            InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('comment').downcase}",
                                   callback_data: router.g(:content, :take_answer, id: entity.tb_id,
                                                                                   p: [router_parameters]).link)
          end
        end
      end
    end
  end
end
