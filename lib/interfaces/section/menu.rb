# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section
        class Menu < Teachbase::Bot::Interfaces::Menu
          CHOOSING_BUTTONS = %i[show_avaliable show_all find_by_query_num].freeze

          def main
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @type = :menu_inline
            @slices_count = 3
            @disable_web_page_preview = false
            @buttons = main_buttons
            @text = [create_title(title_params), entity.statistics, entity.categories_name, description,
                     entity.sign_aval_sections_count_from].compact.join("\n")

            @mode ||= :none
            self
          end

          def show_by_option(sections, option)
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @type = :menu_inline
            @disable_notification = true
            @mode ||= option == :find_by_query_num ? :none : :edit_msg
            @text ||= [create_title(title_params), build_list_with_state(sections.sort_by(&:position))].join("\n")
            @buttons = InlineCallbackKeyboard.collect(buttons: [], back_button: back_button).raw
            self
          end

          def contents
            raise "Entity must be a Section" unless entity.is_a?(Teachbase::Bot::Section)

            @type = :menu_inline
            @mode ||= :nonne
            @buttons = contents_buttons
            @text = "#{create_title(object: entity.course_session,
                                    stages: %i[title], params: { cover_url: '' })}#{create_title(title_params)}"
            self
          end

          private

          def build_list_with_state(sections)
            result = []
            sections.each do |section|
              result << section.title_with_state(state: section.find_state,
                                                 route: router.section(path: :entity, position: section.position,
                                                                       p: [cs_id: entity.tb_id]).link)
            end
            return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if result.empty?

            result.join("\n")
          end

          def main_buttons
            buttons_actions = []
            CHOOSING_BUTTONS.each do |choose_button|
              buttons_actions << router.cs(path: :sections, id: entity.tb_id,
                                           p: [param: choose_button]).link
            end
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(CHOOSING_BUTTONS),
                                     buttons_actions: buttons_actions,
                                     back_button: back_button).raw
          end

          def contents_buttons
            buttons_list = []
            contents_by_types = entity.contents_by_types
            contents_by_types.keys.each do |content_type|
              type_by_section = Teachbase::Bot::Section::OBJECTS_TYPES[content_type.to_sym]
              contents_by_types[content_type].each { |content| buttons_list << build_content_button(content, type_by_section) }
            end
            buttons_list = buttons_list.sort_by(&:position)
            buttons_list.unshift(build_addition_links_button) if entity.links_count.positive?
            InlineCallbackKeyboard.collect(buttons: buttons_list,
                                           back_button: back_button).raw
          end

          def build_content_button(content, type_by_section)
            InlineCallbackButton.g(button_sign: button_sign_by_content_type(type_by_section.to_s, content),
                                   callback_data: router.content(path: :entity, id: content.tb_id,
                                                                 p: [cs_id: cs_tb_id, sec_id: content.section_id, type: type_by_section]).link,
                                   position: content.position)
          end

          def build_addition_links_button
            InlineCallbackButton.g(callback_data: router.section(path: :additions, id: entity.id, p: [cs_id: cs_tb_id]).link,
                                   button_sign: I18n.t('attachments').to_s, emoji: :link)
          end
        end
      end
    end
  end
end
