module Teachbase
  module API
    class MethodEntity
      include Teachbase::API::ParamChecker
      include Teachbase::API::MethodCaller

      attr_reader :url_ids, :request_options

      def initialize(url_ids, request_options)
        @url_ids = url_ids
        @request_options = request_options
      end
    end
  end
end
