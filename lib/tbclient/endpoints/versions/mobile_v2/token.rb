require "json"
require "rest-client"
require './lib/tbclient/request_default_param'

module Teachbase
  module API
    module EndpointsVersion
      module MobileV2
        class Token
          include RequestDefaultParam
          include Teachbase::API::LoadChecker
          include Teachbase::API::LoadHelper

          def initialize(request)
            raise "'#{request}' must be 'Teachbase::API::Request'" unless request.is_a?(Teachbase::API::Request)

            @request = request
          end

          def tokens
            send_request method: :post
          end

          def revoke
            send_request method: :post
          end
        end
      end
    end
  end
end
