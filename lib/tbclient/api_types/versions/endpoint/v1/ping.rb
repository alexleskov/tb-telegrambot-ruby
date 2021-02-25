module Teachbase
  module API
    module Types
      module Endpoint
        module V1
          class Ping < MethodEntity
            SOURCE = "_ping".freeze

            def ping
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
