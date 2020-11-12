module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Materials < MethodEntity
            SOURCE = "course_sessions".freeze

            def course_sessions_materials
              check!(:ids, %i[session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:session_id]}/materials/#{url_ids[:id]}"
            end
          end
        end
      end
    end
  end
end
