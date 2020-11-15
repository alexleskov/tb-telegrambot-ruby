# frozen_string_literal: true

module Teachbase
  module Bot
    class UserLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = { "name" => :first_name }.freeze

      attr_reader :lms_info

      def model_class
        Teachbase::Bot::User
      end

      def me
        profile_loader = profile
        profile_loader.me
        return unless profile_loader.lms_info.is_a?(Hash)

        update_data(profile_loader.lms_info.merge!("tb_id" => profile_loader.lms_info["id"]))
        db_entity
      end

      def profile
        Teachbase::Bot::ProfileLoader.new(appshell)
      end

      def accounts
        Teachbase::Bot::AccountLoader.new(appshell)
      end

      def documents
        Teachbase::Bot::DocumentLoader.new(appshell)
      end

      def db_entity(_mode = :no_create)
        appshell.user
      end
    end
  end
end
