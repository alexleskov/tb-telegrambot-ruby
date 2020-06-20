# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module CourseSession
        MAIN_BUTTONS = %w[open course_results].freeze
        MAIN_BUTTONS_EMOJI = %i[mortar_board information_source].freeze
        STATE_BUTTONS = %w[active archived update].freeze
        STATE_EMOJI = %i[green_book closed_book arrows_counterclockwise].freeze

        def menu_course_main(params)
          answer.menu.create({ buttons: course_main_buttons(params[:callback_data]),
                               text: params[:text],
                               slices_count: MAIN_BUTTONS.size }.merge!(default_menu_params))
        end

        def menu_course_states(params)
          answer.menu.create({ buttons: course_state_buttons(params[:command_prefix]),
                               text: params[:text],
                               slices_count: 2 }.merge!(default_menu_params))
        end

        private

        def course_main_buttons(callbacks)
          raise "Callback must be an Array. Given: '#{callbacks.class}'" unless callbacks.is_a?(Array)

          InlineCallbackKeyboard.g(buttons_signs: to_i18n(MAIN_BUTTONS),
                                   buttons_actions: callbacks,
                                   emojis: MAIN_BUTTONS_EMOJI).raw
        end

        def course_state_buttons(command_prefix)
          InlineCallbackKeyboard.g(buttons_signs: to_i18n(STATE_BUTTONS, command_prefix),
                                   buttons_actions: STATE_BUTTONS,
                                   command_prefix: command_prefix,
                                   emojis: STATE_EMOJI).raw
        end

        def default_menu_params
          { mode: :none, type: :menu_inline }
        end
      end
    end
  end
end
