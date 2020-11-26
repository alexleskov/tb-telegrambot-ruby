# frozen_string_literal: true

module Teachbase
  module Bot
    module Webhook
      class Controller
        def initialize(request)
          @request = request
          $logger.debug "webhook: #{request.data}"
        end
      end
    end
  end
end
