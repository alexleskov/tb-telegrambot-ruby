# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Profile
          def profile
            appshell.data_loader.user.profile.me
            user = appshell.user
            return interface.sys.text.on_empty unless user.profile && user

            interface.user(user).text.profile
          end

          def profile_links
            links = appshell.data_loader.user.profile.links
            return interface.sys.text.on_empty if links.empty?

            links.each do |link_param|
              interface.sys.text.link(link_param["url"], link_param["label"])
            end
          end

          alias more_actions profile_links
        end
      end
    end
  end
end