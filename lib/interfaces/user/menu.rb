# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class User
        class Menu < Teachbase::Bot::Interfaces::Menu
          def profile(account_id)
            @type = :menu_inline
            @mode ||= :none
            @text = "#{text}#{entity.profile_info(account_id)}"
            @disable_web_page_preview = :false
            @buttons = InlineCallbackKeyboard.collect(buttons: [build_accounts_button, build_send_message_button],
                                                      back_button: back_button).raw
            self
          end
        end
      end
    end
  end
end
