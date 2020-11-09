# frozen_string_literal: true

module Teachbase
  module Bot
    class UserLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = { "name" => :first_name }.freeze

      attr_reader :lms_info

      def me
        lms_load(data: :profile)
        return unless lms_info.is_a?(Hash)

        update_data(lms_info.merge!("tb_id" => lms_info["id"]))
        profile.me
        db_entity
      end

      def profile
        Teachbase::Bot::ProfileLoader.new(self)
      end

      def accounts
        Teachbase::Bot::AccountLoader.new(self)
      end

      def db_entity(_mode = :none)
        appshell.user
      end

      def model_class
        Teachbase::Bot::User
      end

      private

      def lms_load(options)
        @lms_info = call_data do
          case options[:data].to_sym
          when :profile
            appshell.authsession.load_profile
          when :accounts
            appshell.authsession.load_user_accounts
          else
            raise "Can't call such data: '#{options[:data]}'"
          end
        end
      end
    end
  end
end
