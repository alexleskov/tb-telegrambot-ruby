# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Profile
          def profile
            appshell.data_loader.user.profile.me
            user = appshell.user
            return interface.sys.text.on_empty.show unless user.profile && user

            interface.user(user).menu.profile.show
          end

          def profile_links
            links = appshell.data_loader.user.profile.links
            return interface.sys.text.on_empty.show if links.empty?

            links.each do |link_param|
              interface.sys.send(:content, link: link_param["url"], link_name: link_param["label"]).url
            end
          end

          alias more_actions profile_links
        end
      end
    end
  end
end
