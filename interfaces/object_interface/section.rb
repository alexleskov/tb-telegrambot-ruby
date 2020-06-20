# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Section
        CHOOSING_BUTTONS = %i[find_by_query_num show_avaliable show_unvaliable show_all].freeze

        def menu_section_main(params)
          answer.menu.create(buttons: section_main_buttons(params),
                             mode: :none,
                             type: :menu_inline,
                             text: params[:text],
                             slices_count: 3)
        end

        def menu_section_contents(params)
          answer.menu.create(buttons: section_contents_buttons(params),
                             mode: :none,
                             type: :menu_inline,
                             text: params[:text])
        end

        private

        def section_main_buttons(params)
          InlineCallbackKeyboard.g(buttons_signs: to_i18n(CHOOSING_BUTTONS),
                                   buttons_actions: CHOOSING_BUTTONS,
                                   command_prefix: params[:command_prefix],
                                   back_button: { mode: :basic, sent_messages: @tg_user.tg_account_messages}).raw
        end

        def section_contents_buttons(params)
          buttons = []
          contents = params[:contents]
          contents.keys.each do |content_type|
            contents[content_type].each { |content| buttons << build_cont_button(content, content_type) }
          end
          InlineCallbackKeyboard.collect(buttons: buttons,
                                         back_button: params[:back_button]).raw
        end

        def build_cont_button(content, content_type)
          cs_tb_id = content.course_session.tb_id
          InlineCallbackButton.g(button_sign: content.button_sign(content_type).to_s,
                                 callback_data: "open_content:#{content_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}")
        end
      end
    end
  end
end
