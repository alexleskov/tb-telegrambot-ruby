# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section
        class Content < Teachbase::Bot::Interfaces::Content
          def main
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @params[:type] = :menu_inline
            @params[:slices_count] = 3
            @params[:disable_web_page_preview] = false
            @params[:buttons] = main_buttons
            @params[:caption] = [create_title(title_params), entity.statistics, entity.categories_name, description,
                                 entity.sign_aval_sections_count_from].compact.join("\n")
            @params[:file] = entity.icon_url
            @params[:mode] ||= :none
            self
          end

          def show_by_option(sections, option)
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @params[:type] = :menu_inline
            @disable_notification = true
            @params[:mode] ||= option == :find_by_query_num ? :none : :edit_msg
            @params[:caption] ||= [create_title(title_params), build_list_with_state(sections.sort_by(&:position))].join("\n")
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: [], back_button: back_button).raw
            @params[:file] = entity.icon_url
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
            Teachbase::Bot::Interfaces::Section::CHOOSING_BUTTONS.each do |choose_button|
              buttons_actions << router.g(:cs, :sections, id: entity.tb_id, p: [param: choose_button]).link
            end
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(Teachbase::Bot::Interfaces::Section::CHOOSING_BUTTONS),
                                     buttons_actions: buttons_actions,
                                     back_button: back_button).raw
          end
        end
      end
    end
  end
end