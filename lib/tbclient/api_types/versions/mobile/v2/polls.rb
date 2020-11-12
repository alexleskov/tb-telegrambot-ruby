module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Polls < MethodEntity
            SOURCE = "course_sessions".freeze

            def course_sessions_polls
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/polls/#{url_ids[:id]}"
            end

            def course_sessions_polls_questions
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/polls/#{url_ids[:id]}/questions" 
            end

            def course_sessions_polls_submit
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/polls/#{url_ids[:id]}/submit"
            end

            def course_sessions_polls_track
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/polls/#{url_ids[:id]}/track"
            end
          end
        end
      end
    end
  end
end
