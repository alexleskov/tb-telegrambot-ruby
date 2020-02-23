module Teachbase
  module API
    module MethodCaller
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def call(method_name, url_ids = {}, request_options = {})
          instance = new(url_ids, request_options)
          instance.public_send(method_name) if instance.respond_to?(method_name)
        end
      end
    end
  end
end
