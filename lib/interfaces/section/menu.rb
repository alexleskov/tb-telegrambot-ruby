# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section
        class Menu < Teachbase::Bot::InterfaceController
          CHOOSING_BUTTONS = %i[find_by_query_num show_avaliable show_unvaliable show_all].freeze

          def main
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            answer.menu.create(buttons: main_buttons,
                               mode: :none,
                               type: :menu_inline,
                               text: "#{create_title(params)}#{entity.sign_aval_sections_count_from}",
                               slices_count: 3)
          end

          def show_by_option(sections, option)
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            params[:mode] ||= option == :find_by_query_num ? :none : :edit_msg
            answer.menu.back(text: "#{create_title(params)}#{build_list_msg_with_state(sections)}",
                             mode: params[:mode])
          end

          def contents
            answer.menu.create(buttons: contents_buttons,
                               mode: :none,
                               type: :menu_inline,
                               text: "#{create_title(params)}") 
          end

          private

          def build_list_msg_with_state(sections)
            mess = []
            sections.each do |section|
              mess << section.title_with_state(section.find_state)
            end
            return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if mess.empty?

            mess.join("\n")
          end

          def main_buttons
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(CHOOSING_BUTTONS),
                                     buttons_actions: CHOOSING_BUTTONS,
                                     command_prefix: params[:command_prefix],
                                     back_button: params[:back_button]).raw
          end

          def contents_buttons
            buttons = []
            contents = entity.contents_by_types
            contents.keys.each do |content_type|
              contents[content_type].each { |content| buttons << build_content_button(content, content_type) }
            end
            buttons = buttons.sort_by(&:position)
            InlineCallbackKeyboard.collect(buttons: buttons,
                                           back_button: params[:back_button]).raw
          end

          def build_content_button(content, content_type)
            InlineCallbackButton.g(button_sign: button_sign(content_type.to_s, content),
                                   callback_data: "open_content:#{content_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}",
                                   position: content.position)
          end

        end
      end
    end
  end
end