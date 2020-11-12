module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Notifications < MethodEntity
            SOURCE = "users".freeze

            def users_notfications
              "#{SOURCE}/notifications"
            end

            def users_notfications_count
              "#{users_notfications}/count"
            end

            def users_notfications_read
              check!(:ids, [:id], url_ids)
              "#{users_notfications}/#{url_ids[:id]}/read"
            end
          end
        end
      end
    end
  end
end
