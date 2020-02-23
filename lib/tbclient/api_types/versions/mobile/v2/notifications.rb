module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Notifications
            SOURCE = "users".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

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
