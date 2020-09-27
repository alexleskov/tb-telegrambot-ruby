module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class User
            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def profile
              "profile"
            end

            def accounts
              "user_accounts"
            end
          end
        end
      end
    end
  end
end
