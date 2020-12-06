module Teachbase
  module API
    module Types
      module Endpoint
        module V1
          class Users < MethodEntity
            SOURCE = "users".freeze

            def users_create
              "#{SOURCE}/create"
            end
          end
        end
      end
    end
  end
end
