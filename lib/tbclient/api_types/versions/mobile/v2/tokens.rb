module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Tokens < MethodEntity
            SOURCE = "tokens".freeze

            def tokens
              SOURCE.to_s
            end

            def tokens_revoke
              "#{SOURCE}/revoke"
            end
          end
        end
      end
    end
  end
end
