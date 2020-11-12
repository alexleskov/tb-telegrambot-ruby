module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class OfflineEvents < MethodEntity
            SOURCE = "offline_events".freeze

            def offline_events
              if url_ids
                check!(:ids, [:id], url_ids)
                "#{SOURCE}/#{url_ids[:id]}"
              else
                check!(:options, [:filter], request_options)
                SOURCE.to_s
              end
            end
          end
        end
      end
    end
  end
end
