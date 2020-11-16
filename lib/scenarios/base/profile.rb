# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Profile
          def profile
            appshell.data_loader.user.profile.me
            user = appshell.user
            return interface.sys.text.on_empty.show unless profile_by(user.id)

            interface.user(user).menu.profile(appshell.current_account.id).show
          end

          def profile_by(user_id)
            Teachbase::Bot::Profile.find_by(account_id: appshell.current_account.id, user_id: user_id)
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
