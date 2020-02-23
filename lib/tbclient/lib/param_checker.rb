module Teachbase
  module API
    module ParamChecker
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods; end

      def check(mode, params, check_data)
        raise "Params for checker must be an Array. You used class: '#{params.class}'" unless params.is_a?(Array)
        raise "Data for checking must be a Hash. You used class: '#{check_data.class}'" unless check_data.is_a?(Hash)

        case mode
        when :ids
          raise "Url ids not exists. Set in request: '#{params}'" unless url_ids
        when :options
          raise "Can't find data for checking. Given: '#{check_data}'" unless check_data
        else
          raise "Can't find such param for checking: #{params}"
        end

        @lost_params = []
        params.each do |param|
          @lost_params << param unless check_data.keys.include?(param)
        end
        @lost_params.empty?
      end
      
      def check!(mode, params, check_data)
        raise "Can't find several #{mode} for this request. Lost: #{@lost_params}" unless check(mode, params, check_data)
      end
    end
  end
end
