module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class CourseSessions
            SOURCE = "course_sessions".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def course_sessions
              if url_ids
                check!(:ids, [:id], url_ids)
                "#{SOURCE}/#{url_ids[:id]}"
              else
                check!(:options, [:filter], request_options)
                SOURCE.to_s
              end
            end

            def course_sessions_complete
              check!(:ids, [:id], url_ids)
              "#{course_sessions}/complete"
            end

            def course_sessions_content
              check!(:ids, [:id], url_ids)
              "#{course_sessions}/content"
            end
          end
        end
      end
    end
  end
end
