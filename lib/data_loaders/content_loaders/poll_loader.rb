# frozen_string_literal: true

module Teachbase
  module Bot
    class PollLoader < Teachbase::Bot::ContentLoaderController
      CUSTOM_ATTRS = {}.freeze
      METHOD_CNAME = :polls

      def model_class
        Teachbase::Bot::Poll
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_poll(cs_tb_id, tb_id) }
      end
    end
  end
end
