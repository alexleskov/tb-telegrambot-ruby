# frozen_string_literal: true

module Teachbase
  module Bot
    class ProfileLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = {}.freeze

      attr_reader :lms_info

      def model_class
        Teachbase::Bot::Profile
      end

      def me
        lms_load
        update_data(lms_info)
      end

      def links
        me
        lms_info["links"].reject! { |hash| hash.values.any?(&:empty?) }
      end

      def db_entity(mode = :with_create)
        if mode == :with_create
          model_class.find_or_create_by!(user_id: appshell.user.id, account_id: appshell.current_account.id)
        else
          model_class.find_by(user_id: appshell.user.id, account_id: appshell.current_account.id)
        end
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_profile }
      end
    end
  end
end
