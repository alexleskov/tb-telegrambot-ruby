module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class SocialOauth < MethodEntity
            SOURCE = "oauth".freeze

            def oauth
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
