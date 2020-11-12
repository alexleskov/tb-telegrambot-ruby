module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class PushTokens < MethodEntity
            SOURCE = "users".freeze

            def push_token
              "#{SOURCE}/push_token"
            end
          end
        end
      end
    end
  end
end
