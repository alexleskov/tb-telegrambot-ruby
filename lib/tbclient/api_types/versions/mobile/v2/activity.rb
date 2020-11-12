module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Activity < MethodEntity
            SOURCE = "user_activity".freeze

            def user_activity
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
