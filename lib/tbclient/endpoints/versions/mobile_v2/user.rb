require "json"
require "rest-client"
require './lib/tbclient/request_default_param'

module Teachbase
  module API
    module EndpointsVersion
      module MobileV2
        class User
          include RequestDefaultParam
          include Teachbase::API::LoadChecker
          include Teachbase::API::LoadHelper

          def initialize(request)
            raise "'#{request}' must be 'Teachbase::API::Request'" unless request.is_a?(Teachbase::API::Request)

            @request = request
          end

          def notifications
            check :method
            check_and_apply_default_req_params
            send_request method: request.http_method
          end

          def notifications_count
            send_request
          end

          def notifications_read
            send_request :with_ids, ids_count: 1
          end

          def push_token
            check :method
            send_request method: request.http_method
          end
        end
      end
    end
  end
end
