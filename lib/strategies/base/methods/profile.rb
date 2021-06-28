# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Base
        class Profile < Teachbase::Bot::Strategies
          def me(user_id = nil)
            on_account = appshell.current_account
            on_user = find_user(user_id)
            return interface.sys.text.on_empty.show unless on_user&.current_profile(on_account.id)

            interface.user(on_user).menu(menu_options(on_user)).profile(on_account.id).show
          end

          def links
            links_list = appshell.data_loader.user.profile.links
            return interface.sys.text.on_empty.show if links_list&.empty?

            interface.sys.menu(text: Phrase.more_actions, mode: :none).links(links_list).show
          end

          private

          def find_user(user_id)
            return appshell.current_account.users.find_by(tb_id: user_id) if user_id

            appshell.data_loader.user.profile.me
            appshell.user
          end

          def menu_options(on_user)
            menu_options = {}
            if on_user.id != appshell.user.id
              menu_options[:send_message_button] = true
            else
              menu_options[:text] = "#{Phrase.profile}\n\n"
              menu_options[:accounts_button] = true
            end
            menu_options
          end
        end
      end
    end
  end
end
