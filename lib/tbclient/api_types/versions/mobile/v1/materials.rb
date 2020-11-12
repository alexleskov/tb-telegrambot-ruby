module Teachbase
  module API
    module Types
      module Mobile
        module V1
          class Materials
            SOURCE = "course_sessions".freeze

            def course_sessions_materials
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/materials/#{url_ids[:id]}"
            end
          end
        end
      end
    end
  end
end
