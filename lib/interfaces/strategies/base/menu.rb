# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Base
        class Menu < Teachbase::Bot::Interfaces::Core::Menu
          def links(links_list)
            raise unless links_list.is_a?(Array)

            @type = :menu_inline
            @mode ||= :edit_msg
            @text ||= "#{create_title(title_params)} \u21B3 #{Phrase.links}"
            @buttons = InlineUrlKeyboard.collect(buttons: build_links_buttons(links_list), back_button: back_button).raw
            self
          end
        end
      end
    end
  end
end
