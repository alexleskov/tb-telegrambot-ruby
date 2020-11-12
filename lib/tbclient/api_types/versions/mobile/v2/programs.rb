module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Programs < MethodEntity
            SOURCE = "programs".freeze

            def programs
              if url_ids
                check!(:ids, [:id], url_ids)
                "#{SOURCE}/#{url_ids[:id]}"
              else
                check!(:options, [:filter], request_options)
                SOURCE.to_s
              end
            end

            def programs_content
              check!(:ids, [:id], url_ids)
              "#{programs}/content"
            end
          end
        end
      end
    end
  end
end
