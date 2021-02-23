module Teachbase
  module API
    module Types
      module Endpoint
        module V1
          class Ping < MethodEntity
            SOURCE = "_ping".freeze

            def ping
              "#{SOURCE}"
            end
          end
        end
      end
    end
  end
end
