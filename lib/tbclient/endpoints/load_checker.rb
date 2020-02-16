module Teachbase
  module API
    module LoadChecker
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods; end

      def check(param = :easy_mode, *args)
        raise "Can't find arguments for checking: #{args}" unless args

        result = []
        args.each do |arg|
          result << find_checker(arg.to_sym)
        end
        case param
        when :easy_mode
          raise "Must set any of '#{args}' param for this API method" if result.all?(false)
        when :strong_mode
          raise "Must set all of '#{args}' param for this API method" if result.any?(false)
        end
      end

      private

      def find_checker(arg)
        case arg
        when :ids
          !request.url_ids.nil?
        when :filter
          request.request_params.keys.include?(:filter)
        when :method
          %i[post delete get patch].include?(request.http_method)
        else
          raise "Don't know such argument for checking: #{arg}"
        end
      end
    end
  end
end
