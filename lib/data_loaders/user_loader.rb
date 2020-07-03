# frozen_string_literal: true

module Teachbase
  module Bot
    class UserLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = { "name" => :first_name }.freeze

      attr_reader :lms_info

      def me
        lms_load        
        update_data(lms_info.merge!("tb_id" => lms_info["id"]))
      end

      def profile
        Teachbase::Bot::ProfileLoader.new(self).me
      end

      def db_entity(mode = :none)
        call_data { appshell.user }
      end

      def model_class
        Teachbase::Bot::User
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_profile }
      end

    end
  end
end