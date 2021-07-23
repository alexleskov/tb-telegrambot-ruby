# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section
        class Content < Teachbase::Bot::Interfaces::Content
          def main
            raise "Entity must be a CourseSession" unless entity.is_a?(Teachbase::Bot::CourseSession)

            @params[:type] = :menu_inline
            @params[:slices_count] = 2
            @params[:disable_web_page_preview] = false
            @params[:buttons] = main_buttons
            @params[:caption] = [create_title(title_params), entity.statistics, entity.categories_name, description,
                                 entity.sign_aval_sections_count_from].compact.join("\n")
            @params[:file] = entity.icon_url
            @params[:mode] ||= :none
            self
          end

          private

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
