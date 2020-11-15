# frozen_string_literal: true

module Teachbase
  module Bot
    class AccountLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = {}.freeze

      attr_reader :tb_id, :lms_info

      def model_class
        Teachbase::Bot::Account
      end

      def avaliable_list
        lms_load
        avaliable_accounts = connected_accounts
        return if avaliable_accounts.empty?

        update_accounts_info(avaliable_accounts)
        avaliable_accounts.order(name: :asc)
      end

      def db_entity(_mode = :no_create)
        model_class.find_by!(tb_id: tb_id)
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_user_accounts }
      end

      def connected_accounts
        avaliable_accounts_ids =
          lms_info.map do |account_by_lms|
            next unless account_by_lms["status"] == "enabled"

            account_by_lms["id"]
          end
        Teachbase::Bot::Account.find_all_matches_by_tbid(avaliable_accounts_ids)
      end

      def update_accounts_info(avaliable_accounts)
        avaliable_accounts.pluck(:tb_id).each do |avaliable_account_tb_id|
          lms_info.each do |avaliable_account_by_lms|
            next unless avaliable_account_by_lms["id"] == avaliable_account_tb_id

            @tb_id = avaliable_account_tb_id
            update_data(avaliable_account_by_lms, :no_create)
          end
        end
      end
    end
  end
end
