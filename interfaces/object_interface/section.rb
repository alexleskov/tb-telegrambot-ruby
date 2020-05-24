# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Section
        CHOOSING_BUTTONS = %i[find_by_query_num show_avaliable show_unvaliable show_all].freeze

        def menu_section_main(params)
          answer.menu.create(buttons: section_main_buttons(params[:command_prefix], params[:back_button]),
                             mode: :none,
                             type: :menu_inline,
                             text: params[:text],
                             slices_count: 3)
        end

        def menu_section_contents(section, contents, params)
          answer.menu.create(buttons: section_contents_buttons(contents) + section.course_session.back_button,
                             mode: :none,
                             type: :menu_inline,
                             text: params[:text])
        end

        private

        def section_main_buttons(command_prefix, back_button)
          InlineCallbackButton.g(buttons_sign: to_i18n(CHOOSING_BUTTONS),
                                 callback_data: CHOOSING_BUTTONS,
                                 command_prefix: command_prefix,
                                 sent_messages: @tg_user.tg_account_messages,
                                 back_button: back_button)
        end

        def section_contents_buttons(contents)
          @buttons_sign = []
          @callbacks_data = []
          contents.keys.each do |content_type|
            contents[content_type].each { |content| build_conts_buttons_params(content, content_type) }
          end
          InlineCallbackButton.g(buttons_sign: @buttons_sign,
                                 callback_data: @callbacks_data)
        end

        def build_conts_buttons_params(content, content_type)
          cs_tb_id = content.course_session.tb_id
          @buttons_sign << "#{content.button_sign(content_type)}"
          @callbacks_data << "open_content:#{content_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}"
        end
      end
    end
  end
end