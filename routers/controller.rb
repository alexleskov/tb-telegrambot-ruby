# frozen_string_literal: true

module Teachbase
  module Bot
    class Routers
      class Controller
        attr_reader :path, :parameters, :id, :routers

        def initialize(options, routers)
          raise "Must have Routers. Given: '#{routers.class}'" unless routers.is_a?(Teachbase::Bot::Routers)

          @path = options[:path]
          @parameters = options[:p]
          @id = options[:id] || options[:position]
          @routers = routers
          raise "Can't find such path: '#{path}'. For #{self.class}" unless respond_to?(path)
        end

        def regexp
          /^#{link}$/
        end

        def link
          "#{root_class::PREFIX}#{build_path}"
        end

        def start
          [root_class::START]
        end

        def logout
          [root_class::LOGOUT]
        end

        def login
          [root_class::LOGIN]
        end

        def root
          [self.class::SOURCE]
        end

        def list
          [self.class::SOURCE, root_class::LIST]
        end

        def entity
          value = id ? id : Teachbase::Bot::Routers::DIGIT_REGEXP
          ["#{self.class::SOURCE}#{value}"]
        end

        def build_path
          result = public_send(path)
          result = parameters ? add_parameters(result) : result
          "#{result.join(root_class::DELIMETER)}"
        end
      
      protected

        def root_class
          Teachbase::Bot::Routers
        end

        def add_parameters(path_result)
          path_on_change = path_result.dup
          parameters.each do |parameter|
            if parameter.is_a?(Hash)
              parameter.each { |key, value| path_on_change.insert(0, root_class.public_send(key, value)) }
            else
              path_on_change.insert(0, root_class.public_send(parameter))
            end
          end
          path_on_change
        end
      end
    end
  end
end