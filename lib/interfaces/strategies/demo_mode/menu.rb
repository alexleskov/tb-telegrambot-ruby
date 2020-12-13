# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class DemoMode
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def after_auth
            @type = :menu
            @slices_count = 2
            @text ||= I18n.t('start_menu_message').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands,
                                             buttons_signs: %i[studying user_profile documents more_actions settings_list sign_out]).raw
            self
          end

          def take_contact
            @type = :menu
            @mode ||= :none
            @text ||= "#{I18n.t('meet_with_bot')}\n\n#{Emoji.t(:point_down)} #{I18n.t('click_to_send_contact')}"
            @buttons = TextCommandKeyboard.collect(buttons: [TextCommandButton.take_contact(init_commands)]).raw
            self
          end

          def greetings(user_name, custom_text = "")
            @type = :hide_kb
            @disable_web_page_preview ||= false
            @text ||= "<b>#{I18n.t('greeting_message')} #{user_name}!</b>\n\n#{custom_text}"
            self
          end
        end
      end
    end
  end
end