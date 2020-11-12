module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class NotificationSettings < MethodEntity
            SOURCE = "profile".freeze

            def profile_notification_settings
              "#{SOURCE}/notification_settings"
            end
          end
        end
      end
    end
  end
end
