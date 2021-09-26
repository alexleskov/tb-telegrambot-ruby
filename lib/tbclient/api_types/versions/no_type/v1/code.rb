module Teachbase
  module API
    module Types
      module NoType
        module V1
          class Code < MethodEntity
            SOURCE = "".freeze

            def one_time_code
              "one_time_code"
            end
          end
        end
      end
    end
  end
end
