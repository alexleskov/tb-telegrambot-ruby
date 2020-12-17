# frozen_string_literal: true

require './routers/controller/'
require './routers/course_session/'
require './routers/section/'
require './routers/content/'
require './routers/setting/'
require './routers/document/'
require './routers/user/'

module Teachbase
  module Bot
    class Routers
      DELIMETER = "_"
      PREFIX = "/"
      STRING_REGEXP = "(\\w*)"
      DIGIT_REGEXP = "(\\d*)"
      EDIT = "edit"
      LIST = "list"
      START = "start"
      LOGOUT = "close"
      LOGIN = "sign_in"
      PASSWORD = "password"
      ACCOUNTS = "accounts"
      DOCUMENTS = "documents"
      SEND_MESSAGE = "send_message"
      FIND = "find"
      HELP = "help"

      class << self
        def param(value = STRING_REGEXP)
          "p:#{value}"
        end

        def type(value = STRING_REGEXP)
          "t:#{value}"
        end

        def answer_type(value = STRING_REGEXP)
          "at:#{value}"
        end

        def limit(value = DIGIT_REGEXP)
          "limit:#{value}"
        end

        def offset(value = DIGIT_REGEXP)
          "offset:#{value}"
        end

        def time(value = DIGIT_REGEXP)
          "time:#{value}"
        end

        def cs_id(value = DIGIT_REGEXP)
          "#{Teachbase::Bot::Routers::CourseSession::SOURCE}#{value}"
        end

        def sec_id(value = DIGIT_REGEXP)
          "#{Teachbase::Bot::Routers::Section::SOURCE}#{value}"
        end

        def u_id(value = DIGIT_REGEXP)
          "#{Teachbase::Bot::Routers::User::SOURCE}#{value}"
        end
      end

      def main(options)
        Teachbase::Bot::Routers::Controller.new(options, self)
      end

      def cs(options)
        Teachbase::Bot::Routers::CourseSession.new(options, self)
      end

      def section(options)
        Teachbase::Bot::Routers::Section.new(options, self)
      end

      def content(options)
        Teachbase::Bot::Routers::Content.new(options, self)
      end

      def setting(options)
        Teachbase::Bot::Routers::Setting.new(options, self)
      end

      def document(options)
        Teachbase::Bot::Routers::Document.new(options, self)
      end

      def user(options)
        Teachbase::Bot::Routers::User.new(options, self)
      end
    end
  end
end
