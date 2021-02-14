# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class Route
        EDIT = "edit"
        LIST = "list"
        DELIMETER = "_"
        PREFIX = "/"

        attr_reader :path, :params, :id, :router_class

        def initialize(path, options = {})
          @path = path
          @params = options[:p]
          @id = options[:id] || options[:position]
          @router_class = options[:router_class] || Teachbase::Bot::Router
        end

        def regexp
          /^#{link}$/
        end

        def link
          "#{PREFIX}#{build}"
        end

        def root
          ["#{self.class::SOURCE}#{id || router_class::DIGIT_REGEXP}"]
        end

        def list
          [self.class::SOURCE, LIST]
        end

        def entity
          ["#{self.class::SOURCE}#{id || router_class::DIGIT_REGEXP}"]
        end

        protected

        def build
          raise "Can't find such path: '#{path}'. For #{self.class}" unless respond_to?(path)

          result = public_send(path)
          result = params ? add_params(result) : result
          result.join(DELIMETER).to_s
        end

        def add_params(path_result)
          path_with_params = path_result.dup
          params.each do |parameter|
            if parameter.is_a?(Hash)
              parameter.each { |key, value| path_with_params << router_class.public_send(key, value) }
            else
              path_with_params << router_class.public_send(parameter)
            end
          end
          path_with_params
        end
      end
    end
  end
end
