# frozen_string_literal: true

module Teachbase
  module Bot
    class QuizLoader < Teachbase::Bot::ContentLoaderController
      CUSTOM_ATTRS = {}.freeze
      METHOD_CNAME = :quizzes

      def model_class
        Teachbase::Bot::Quiz
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_quiz(cs_tb_id, tb_id) }
      end
    end
  end
end
