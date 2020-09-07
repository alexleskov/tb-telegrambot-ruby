# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Menu < Teachbase::Bot::InterfaceController

          def main(course_sessions)
            params[:mode] ||= :none
            answer.menu.custom_back(text: "#{create_title(params)}\n\n#{build_list(course_sessions)}",
                                    mode: params[:mode],
                                    callback_data: router.cs(path: :list, p: [type: :states]).link)
          end

          def states
            params[:mode] ||= :none
            answer.menu.create(buttons: state_buttons,
                               text: params[:text],
                               mode: params[:mode],
                               slices_count: 2,
                               type: :menu_inline)
          end

          private

          def build_list(course_sessions)
            result = []
            course_sessions.each do |cs|
              result << cs.sign_open(cover_url: '', route: router.cs(path: :entity, id: cs.tb_id).link).to_s
            end
            return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if result.empty?

            result.join("\n")
          end

          def state_buttons
            buttons_actions = []
            Teachbase::Bot::CourseSession::STATES.each { |state| buttons_actions << router.cs(path: :list, p: [:param => state.to_s]).link }
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(Teachbase::Bot::CourseSession::STATES.dup << "update", "cs_"),
                                     buttons_actions: buttons_actions << router.cs(path: :list, p: [param: :update]).link).raw
          end
        end
      end
    end
  end
end
