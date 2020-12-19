# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class DemoMode
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def sign_in_again
            @type = :menu_inline
            @buttons = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in(router.main(path: :login).link),
                                                                InlineCallbackButton.reset_password(router.main(path: :password, p: [param: :reset]).link)]).raw
            @mode ||= :none
            @text ||= "#{I18n.t('error')}. #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
            self
          end

          def after_auth
            @type = :menu
            @slices_count = 2
            @text ||= I18n.t('start_menu_message').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands,
                                             buttons_signs: %i[studying user_profile documents more_actions settings_list sign_out]).raw
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
