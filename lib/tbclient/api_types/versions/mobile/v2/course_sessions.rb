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

            def course_sessions_progress
              check!(:ids, [:id], url_ids)
              "#{course_sessions}/progress"
            end

            def course_sessions_materials_track
              check!(:ids, %i[session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:session_id]}/materials/#{url_ids[:id]}/track"
            end
          end
        end
      end
    end
  end
end
