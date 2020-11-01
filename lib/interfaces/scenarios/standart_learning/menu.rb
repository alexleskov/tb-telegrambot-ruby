# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class StandartLearning
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def after_auth
            @type = :menu
            @slices_count = 2
            @text ||= I18n.t('start_menu_message').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands,
                                             buttons_signs: %i[studying profile settings more_actions sign_out]).raw
            self
          end
        end
      end
    end
  end
end
