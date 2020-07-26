# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class ScormPackage
        class Menu < Teachbase::Bot::InterfaceController
          def actions
            params.merge!(type: :menu_inline, disable_web_page_preview: true, disable_notification: true,
                          slices_count: 2, buttons: action_buttons)
            params[:text] ||= I18n.t('start_menu_message')
            params[:mode] ||= :none
            answer.menu.create(params)
          end
        end
      end
    end
  end
end