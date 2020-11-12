module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class User < MethodEntity
            def profile
              "profile"
            end

            def accounts
              "user_accounts"
            end
          end
        end
      end
    end
  end
end
