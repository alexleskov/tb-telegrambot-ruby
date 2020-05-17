# frozen_string_literal: true

module Viewers
  module Menu
    MAIN_BUTTONS = %w[open course_results].freeze
    MAIN_BUTTONS_EMOJI = %i[mortar_board information_source].freeze
    STATE_BUTTONS = %w[active archived update].freeze
    STATE_EMOJI = %i[green_book closed_book arrows_counterclockwise].freeze
    CHOOSING_BUTTONS = %i[find_by_query_num show_avaliable show_unvaliable show_all].freeze

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
             mode: :edit_msg,
             type: :menu_inline,
             text: text,
             slices_count: 3)
    end

    def content_main(buttons, mode = :none)
      create(buttons: buttons, type: :menu_inline, disable_notification: true, mode: mode,
             text: I18n.t('start_menu_message'), slices_count: buttons.size)   
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
                             emoji: STATE_EMOJI)
    end

    def section_main_buttons(command_prefix)
      InlineCallbackButton.g(buttons_sign: to_i18n(CHOOSING_BUTTONS),
                             callback_data: CHOOSING_BUTTONS,
                             command_prefix: command_prefix)
    end
  end
end
