module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class ScormPackages < MethodEntity
            SOURCE = "course_sessions".freeze

            def course_sessions_scorm_packages
              check!(:ids, %i[course_session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:course_session_id]}/scorm_packages/#{url_ids[:id]}"
            end
          end
        end
      end
    end
  end
end
