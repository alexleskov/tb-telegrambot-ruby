# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class DemoMode
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def sign_in_again
            super
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in(router.g(:main, :login).link),
                                                                         InlineCallbackButton.reset_password(router.g(:main, :password, p: [param: :reset]).link)]).raw
            @params[:slices_count] = 2
            self
          end

          def greetings(custom_text = "")
            @params[:type] = :hide_kb
            @params[:disable_web_page_preview] ||= false
            @params[:text] ||= "<b>#{I18n.t('greeting_message')}!</b>\n\n#{custom_text}"
            self
          end
        end
      end
    end
  end
end
