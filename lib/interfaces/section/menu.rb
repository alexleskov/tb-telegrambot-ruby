# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section
        class Menu < Teachbase::Bot::Interfaces::Menu
          CHOOSING_BUTTONS = %i[show_avaliable show_all find_by_query_num].freeze

          def main
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @params[:type] = :menu_inline
            @params[:slices_count] = 3
            @params[:disable_web_page_preview] = false
            @params[:buttons] = main_buttons
            @params[:text] = [create_title(title_params), entity.statistics, entity.categories_name, description,
                              entity.sign_aval_sections_count_from].compact.join("\n")

            @params[:mode] ||= :none
            self
          end

          def show_by_option(sections, option)
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @params[:type] = :menu_inline
            @disable_notification = true
            @params[:mode] ||= option == :find_by_query_num ? :none : :edit_msg
            @params[:text] ||= [create_title(title_params), build_list_with_state(sections.sort_by(&:position))].join("\n")
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: [], back_button: back_button).raw
            self
          end

          def contents
            raise "Entity must be a Section" unless entity.is_a?(Teachbase::Bot::Section)

            @params[:type] = :menu_inline
            @params[:mode] ||= :none
            @params[:buttons] = contents_buttons
            @params[:text] = "#{create_title(object: entity.course_session,
                                             stages: %i[title], params: { cover_url: '' })} \u21B3 #{create_title(title_params)}"
            self
          end

          private

          def build_list_with_state(sections)
            result = []
            sections.each do |section|
              result << section.title_with_state(state: section.find_state,
                                                 route: router.g(:section, :root, position: section.position,
                                                                                  p: [cs_id: entity.tb_id]).link)
            end
            return "\n#{Phrase.empty}" if result.empty?

            result.join("\n\n")
          end

          def main_buttons
            buttons_actions = []
            CHOOSING_BUTTONS.each do |choose_button|
              buttons_actions << router.g(:cs, :sections, id: entity.tb_id, p: [param: choose_button]).link
            end
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(CHOOSING_BUTTONS), buttons_actions: buttons_actions,
                                     back_button: back_button).raw
          end

          def contents_buttons
            buttons_list = []
            contents_by_types = entity.contents_by_types
            contents_by_types.keys.each do |content_type|
              contents_by_types[content_type].each do |content|
                buttons_list << build_content_button(content, Teachbase::Bot::Section::OBJECTS_TYPES[content_type.to_sym])
              end
            end
            buttons_list = buttons_list.sort_by(&:position)
            buttons_list.unshift(build_addition_links_button) if entity.links_count.positive?
            InlineCallbackKeyboard.collect(buttons: buttons_list,
                                           back_button: back_button).raw
          end

          def build_content_button(content, type_by_section)
            router_parameters = { cs_id: content.course_session.tb_id, sec_id: content.section_id, type: type_by_section }
            InlineCallbackButton.g(button_sign: button_sign_by_content_type(type_by_section.to_s, content),
                                   callback_data: router.g(:content, :root, id: content.tb_id,
                                                                            p: [router_parameters]).link,
                                   position: content.position)
          end

          def build_addition_links_button
            InlineCallbackButton.g(callback_data: router.g(:section, :additions, id: entity.id, p: [cs_id: entity.course_session.tb_id]).link,
                                   button_sign: I18n.t('attachments').to_s, emoji: :package)
          end
        end
      end
    end
  end
end
