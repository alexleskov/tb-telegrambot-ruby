# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Menu < Teachbase::Bot::InterfaceController
          MAIN_BUTTONS = %w[open information].freeze
          MAIN_BUTTONS_EMOJI = %i[mortar_board information_source].freeze
          STATE_BUTTONS = %w[active archived update].freeze
          STATE_EMOJI = %i[green_book closed_book arrows_counterclockwise].freeze

          def main
            answer.menu.create({ buttons: main_buttons(params[:callback_data]),
                                 text: create_title(params),
                                 slices_count: MAIN_BUTTONS.size }.merge!(default_params))
          end

          def states
            answer.menu.create({ buttons: state_buttons(params[:command_prefix]),
                                 text: params[:text],
                                 slices_count: 2 }.merge!(default_params))
          end

          def stats_info
            answer.menu.back(text: "#{create_title(params)}#{entity.statistics}\n\n#{description}\n")
          end

          private

          def main_buttons(callbacks)
            raise "Callback must be an Array. Given: '#{callbacks.class}'" unless callbacks.is_a?(Array)

            InlineCallbackKeyboard.g(buttons_signs: to_i18n(MAIN_BUTTONS),
                                     buttons_actions: callbacks,
                                     emojis: MAIN_BUTTONS_EMOJI).raw
          end

          def state_buttons(command_prefix)
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(STATE_BUTTONS, command_prefix),
                                     buttons_actions: STATE_BUTTONS,
                                     command_prefix: command_prefix,
                                     emojis: STATE_EMOJI).raw
          end

          def default_params
            { mode: :none, type: :menu_inline }
          end
        end
      end
    end
  end
end
