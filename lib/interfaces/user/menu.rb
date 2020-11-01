# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class User
        class Menu < Teachbase::Bot::Interfaces::Menu
          def profile
            @type = :menu_inline
            @mode ||= :none
            @text = entity.profile_info
            @disable_web_page_preview = :false
            @buttons = InlineCallbackKeyboard.g(buttons_signs: [I18n.t('accounts').to_s],
                                                buttons_actions: [router.main(path: :accounts).link]).raw
            self
          end
        end
      end
    end
  end
end
