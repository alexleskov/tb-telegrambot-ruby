# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class StandartLearning
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def sign_in_again
            @type = :menu_inline
            @buttons = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in(router.main(path: :login).link)]).raw
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
        end
      end
    end
  end
end
