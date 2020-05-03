module Viewers
  module Menu
    MAIN_BUTTONS = %w[ open course_results ]
    MAIN_BUTTONS_EMOJI = %i[ mortar_board information_source ]
    STATE_BUTTONS = %w[ active archived update ]
    STATE_EMOJI = %i[ green_book closed_book arrows_counterclockwise ]
    CHOOSING_BUTTONS = %i[ find_by_query_num show_avaliable show_unvaliable show_all ]

    def course_main(text, callbacks)
      create(buttons: course_main_buttons(callbacks),
             type: :menu_inline,
             mode: :none,
             text: text,
             slices_count: MAIN_BUTTONS.size)
    end

    def course_states(text)
      create(buttons: course_state_buttons,
             mode: :none,
             type: :menu_inline,
             text: text,
             slices_count: 2)
    end

    def section_main(text, command_prefix, sent_messages)
      back_button = InlineCallbackButton.back(sent_messages)
      create(buttons: section_main_buttons(command_prefix) + back_button,
             mode: :none,
             type: :menu_inline,
             text: text,
             slices_count: 3)
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

    def course_state_buttons
      prefix = "courses_"
      InlineCallbackButton.g(buttons_sign: to_i18n(STATE_BUTTONS, prefix),
                             callback_data: STATE_BUTTONS,
                             command_prefix: prefix,
                             emoji: STATE_EMOJI )
    end

    def section_main_buttons(command_prefix)
      InlineCallbackButton.g(buttons_sign: to_i18n(CHOOSING_BUTTONS),
                             callback_data: CHOOSING_BUTTONS,
                             command_prefix: command_prefix)
    end
  end
end