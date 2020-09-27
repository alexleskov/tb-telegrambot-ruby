# frozen_string_literal: true

module Teachbase
  module Bot
    class AccountLoader < Teachbase::Bot::ProfileLoader
      CUSTOM_ATTRS = {}.freeze

      attr_reader :user_loader, :lms_info

      private

      def lms_load
        @lms_info = call_data { user_loader.send(:lms_load, data: :accounts) }
      end

      def model_class
        Teachbase::Bot::Account
      end
    end
  end
end
