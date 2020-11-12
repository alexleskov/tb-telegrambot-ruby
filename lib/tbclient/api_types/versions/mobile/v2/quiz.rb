module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Quiz < MethodEntity
            SOURCE = "course_sessions".freeze

            def course_sessions_quiz_stats_check
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/quiz_stats/#{url_ids[:id]}"
            end

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
