# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Menu < Teachbase::Bot::InterfaceController
          STATE_BUTTONS = %w[active archived update].freeze
          STATE_EMOJI = %i[green_book closed_book arrows_counterclockwise].freeze

          def main(course_sessions)
            params[:mode] ||= :none
            answer.menu.custom_back(text: "#{create_title(params)}\n\n#{build_list(course_sessions)}",
                                    mode: params[:mode],
                                    callback_data: "courses_list")
          end

          def states
            params[:mode] ||= :none
            answer.menu.create(buttons: state_buttons(params[:command_prefix]),
                               text: params[:text],
                               mode: params[:mode],
                               slices_count: 2,
                               type: :menu_inline)
          end

          private

          def build_list(course_sessions)
            result = []
            course_sessions.each do |course_session|
              result << course_session.sign_open(cover_url: '').to_s
            end
            return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if result.empty?

            result.join("\n")
          end

          def state_buttons(command_prefix)
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(STATE_BUTTONS, command_prefix),
                                     buttons_actions: STATE_BUTTONS,
                                     command_prefix: command_prefix).raw
          end
        end
      end
    end
  end
end
