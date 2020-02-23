module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Activity
            SOURCE = "user_activity".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def user_activity
              SOURCE.to_s
            end
          end
        end
      end
    end
  end
end
