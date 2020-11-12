module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Documents < MethodEntity
            SOURCE = "documents".freeze

            def documents
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
