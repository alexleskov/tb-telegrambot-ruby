module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Quizzes
            SOURCE = "course_sessions".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def course_sessions_questions
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/questions/#{url_ids[:id]}"
            end

            def course_sessions_questions_submit
              check!(:ids, %i[course_session_id id], url_ids)
              "#{course_sessions_questions}/submit"
            end

            def course_sessions_questions_track
              check!(:ids, %i[course_session_id id], url_ids)
              "#{course_sessions_questions}/track"
            end

            def course_sessions_quizzes_start
              check!(:ids, %i[course_session_id id], url_ids)
              "#{course_sessions_quizzes}/start"
            end

            def course_sessions_quizzes_results
              check!(:ids, %i[course_session_id id], url_ids)
              "#{course_sessions_quizzes}/results"
            end

            private

            def course_sessions_quizzes
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/quizzes/#{url_ids[:id]}"
            end
          end
        end
      end
    end
  end
end
