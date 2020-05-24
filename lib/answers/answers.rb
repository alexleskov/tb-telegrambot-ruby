# frozen_string_literal: true

require './lib/answers/answer_controller'
require './lib/answers/answer_menu'
require './lib/answers/answer_text'
require './lib/answers/answer_content'

module Teachbase
  module Bot
    class Answers
      def initialize(respond, dest)
        @respond = respond
        @dest = dest
      end

      def text
        Teachbase::Bot::AnswerText.new(@respond, @dest)
      end

      def menu
        Teachbase::Bot::AnswerMenu.new(@respond, @dest)
      end

      def content
        Teachbase::Bot::AnswerContent.new(@respond, @dest)
      end
    end
  end
end
