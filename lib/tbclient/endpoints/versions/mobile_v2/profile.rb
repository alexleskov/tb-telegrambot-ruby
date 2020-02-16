require "json"
require "rest-client"
require './lib/tbclient/request_default_param'

module Teachbase
  module API
    module EndpointsVersion
      module MobileV2
        class Profile
          include RequestDefaultParam
          include Teachbase::API::LoadChecker
          include Teachbase::API::LoadHelper

          def initialize(request)
            raise "'#{request}' must be 'Teachbase::API::Request'" unless request.is_a?(Teachbase::API::Request)

            @request = request
          end

          def profile
            send_request
          end

          def notification_settings
            check :method
            send_request method: request.http_method
          end
        end
      end
    end
  end
end
