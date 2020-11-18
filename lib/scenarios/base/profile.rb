# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Profile
          def profile(user_id = nil)
            on_account = appshell.current_account
            on_user = user_id ? appshell.current_account.users.find_by(id: user_id) : appshell.user
            return interface.sys.text.on_empty.show unless on_user&.current_profile(on_account.id)

            menu_options = {}
            if on_user.id != appshell.user.id
              menu_options[:send_message_button] = true
            else
              menu_options[:text] = "<b>#{Emoji.t(:tiger)} #{I18n.t('profile_state')}</b>\n\n"
              menu_options[:accounts_button] = true
            end
            interface.user(on_user).menu(menu_options).profile(on_account.id).show
          end

          def profile_links
            links_list = appshell.data_loader.user.profile.links
            return interface.sys.text.on_empty.show if links_list.empty?

            interface.sys.menu(text: "#{Emoji.t(:link)}#{I18n.t('more_actions')}", mode: :none).links(links_list).show
          end

          alias more_actions profile_links
        end
      end
    end
  end
end
