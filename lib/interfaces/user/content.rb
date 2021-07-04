# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class User
        class Content < Teachbase::Bot::Interfaces::Content
          def profile(account_id)
            @params[:type] = :menu_inline
            @params[:mode] ||= :none
            @params[:caption] = "#{params[:text]}#{entity.profile_info(account_id)}"
            @params[:disable_web_page_preview] = false
            @params[:file] = entity.photo
            @params[:buttons] = InlineCallbackKeyboard.collect(buttons: [build_accounts_button, build_send_message_button],
                                                               back_button: back_button).raw
            self
          end
        end
      end
    end
  end
end
