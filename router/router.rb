# frozen_string_literal: true

require './router/route/'
require './router/main/'
require './router/course_session/'
require './router/section/'
require './router/content/'
require './router/setting/'
require './router/document/'
require './router/user/'

module Teachbase
  module Bot
    class Router
      STRING_REGEXP = "(\\w*)"
      DIGIT_REGEXP = "(\\d*)"
      DELIMETER = ":"
      PARAMETER = "p"
      TYPE = "t"
      ANSWER_TYPE = "ans_t"
      LIMIT = "limit"
      OFFSET = "offset"
      TIME = "time"

      class << self
        def param(value = STRING_REGEXP)
          "#{PARAMETER}#{DELIMETER}#{value}"
        end

        def type(value = STRING_REGEXP)
          "#{TYPE}#{DELIMETER}#{value}"
        end

        def answer_type(value = STRING_REGEXP)
          "#{ANSWER_TYPE}#{DELIMETER}#{value}"
        end

        def limit(value = DIGIT_REGEXP)
          "#{LIMIT}#{DELIMETER}#{value}"
        end

        def offset(value = DIGIT_REGEXP)
          "#{OFFSET}#{DELIMETER}#{value}"
        end

        def time(value = DIGIT_REGEXP)
          "#{TIME}#{DELIMETER}#{value}"
        end

        def cs_id(value = DIGIT_REGEXP)
          "#{find_route_class(:cs)::SOURCE}#{value}"
        end

        def sec_id(value = DIGIT_REGEXP)
          "#{find_route_class(:section)::SOURCE}#{value}"
        end

        def u_id(value = DIGIT_REGEXP)
          "#{find_route_class(:user)::SOURCE}#{value}"
        end

        def find_route_class(route_name)
          case route_name.to_sym
          when :main
            Main
          when :cs
            CourseSession
          when :section
            Section
          when :content
            Content
          when :setting
            Setting
          when :document
            Document
          when :user
            User
          else
            raise "Don't know such route name: '#{route_name}'."
          end
        end
      end

      def g(route_name, path, options = {})
        self.class::find_route_class(route_name).new(path, options)
      end
    end
  end
end
