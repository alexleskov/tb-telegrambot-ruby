# frozen_string_literal: true

module Teachbase
  module Bot
    class ProfileLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = {}.freeze

      attr_reader :user_loader

      def initialize(user_loader)
        raise "'#{user_loader}' is not UserLoader" unless user_loader.is_a?(Teachbase::Bot::UserLoader)

        @user_loader = user_loader
        @appshell = user_loader.appshell
      end

      def me
        user_loader.me
        update_data(user_loader.lms_info)
      end

      private

      def db_entity(mode = :with_create)
        call_data do
          case mode
          when :with_create
            model_class.find_or_create_by!(user_id: user_loader.db_entity.id)
          else
            model_class.find_by(user_id: user_loader.db_entity.id)
          end
        end
      end

      def model_class
        Teachbase::Bot::Profile
      end

    end
  end
end