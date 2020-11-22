# frozen_string_literal: true

require './lib/answers/answer_controller'
require './lib/answers/answer_menu'
require './lib/answers/answer_text'
require './lib/answers/answer_content'
require './lib/answers/answer_destroyer'

module Teachbase
  module Bot
    class Answers
      def initialize(config_params, dest)
        @config_params = config_params
        @dest = dest
      end

      def text
        Teachbase::Bot::AnswerText.new(@config_params, @dest)
      end

      def menu
        Teachbase::Bot::AnswerMenu.new(@config_params, @dest)
      end

      def content
        Teachbase::Bot::AnswerContent.new(@config_params, @dest)
      end

      def destroy
        Teachbase::Bot::AnswerDestroyer.new(@config_params, @dest)
      end
    end
  end
end
