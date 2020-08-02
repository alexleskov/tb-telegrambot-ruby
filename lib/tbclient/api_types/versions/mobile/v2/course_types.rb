module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class CourseTypes
            SOURCE = "course_types".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def course_types
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
