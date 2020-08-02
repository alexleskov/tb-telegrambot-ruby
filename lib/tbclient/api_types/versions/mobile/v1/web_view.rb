module Teachbase
  module API
    module Types
      module Mobile
        module V1
          class WebView
            SOURCE = "web_view".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def token
              "#{SOURCE}/token"
            end
          end
        end
      end
    end
  end
end
