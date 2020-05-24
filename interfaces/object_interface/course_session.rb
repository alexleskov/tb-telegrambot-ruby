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
          answer.menu.create(buttons: course_main_buttons(params[:callback_data]),
                             type: :menu_inline,
                             mode: :none,
                             text: params[:text],
                             slices_count: MAIN_BUTTONS.size)
        end

        def menu_course_states(params)
          answer.menu.create(buttons: course_state_buttons(params[:command_prefix]),
                             mode: :none,
                             type: :menu_inline,
                             text: params[:text],
                             slices_count: 2)
        end

        private

        def course_main_buttons(callbacks)
          raise "Callback must be an Array. Given: '#{callbacks.class}'" unless callbacks.is_a?(Array)
          unless callbacks.size == MAIN_BUTTONS.size
            raise "Given '#{callbacks.size}' callbacks for #{MAIN_BUTTONS.size} course buttons."
          end

          InlineCallbackButton.g(buttons_sign: to_i18n(MAIN_BUTTONS),
                                 callback_data: callbacks,
                                 emoji: MAIN_BUTTONS_EMOJI)
        end

        def course_state_buttons(command_prefix)
          InlineCallbackButton.g(buttons_sign: to_i18n(STATE_BUTTONS, command_prefix),
                                 callback_data: STATE_BUTTONS,
                                 command_prefix: command_prefix,
                                 emoji: STATE_EMOJI)
        end
      end
    end
  end
end
