# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Battle
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def after_auth
            @type = :menu
            @slices_count = 2
            @text ||= I18n.t('undefined_action').to_s
            @buttons = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[sign_out]).raw
            self
          end
        end
      end
    end
  end
end
