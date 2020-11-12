module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class CourseTypes < MethodEntity
            SOURCE = "course_types".freeze

            def course_types
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
