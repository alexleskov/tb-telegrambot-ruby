# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Base
        class Menu < Teachbase::Bot::Interfaces::Core::Menu
          def links(links_list)
            raise unless links_list.is_a?(Array)

            @params[:type] = :menu_inline
            @params[:mode] ||= :edit_msg
            @params[:text] ||= "#{create_title(title_params)} \u21B3 #{Phrase.links}"
            @params[:buttons] = InlineUrlKeyboard.collect(buttons: build_links_buttons(links_list), back_button: back_button).raw
            self
          end
        end
      end
    end
  end
end
