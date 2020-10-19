# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class User
        class Menu < Teachbase::Bot::InterfaceController
          def profile
            params.merge!(type: :menu_inline, text: entity.profile_info)
            params[:mode] ||= :none
            params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: ["#{I18n.t('accounts')}"],
                                                        buttons_actions: [router.main(path: :accounts).link]).raw
            answer.menu.create(params)
          end
        end
      end
    end
  end
end
