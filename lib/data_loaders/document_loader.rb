# frozen_string_literal: true

module Teachbase
  module Bot
    class DocumentLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = { "updated_at" => :edited_at, "created_at" => :built_at, "type" => :doc_type }.freeze

      attr_reader :tb_id, :lms_info

      def model_class
        Teachbase::Bot::Document
      end

      def list
        lms_load
        lms_tb_ids = []
        lms_info.each do |object_lms|
          lms_tb_ids << @tb_id = object_lms["id"]
          next if object_lms["updated_at"] == db_entity.edited_at

          update_data(object_lms.merge!("tb_id" => object_lms["id"]))
        end
        delete_unsigned(lms_tb_ids)
        model_class.where(account_id: current_account.id, user_id: appshell.user.id)
      end

      private

      def delete_unsigned(lms_tb_ids)
        db_tb_ids = appshell.user.documents.where(account_id: current_account.id)
                            .order(built_at: :desc).select(:tb_id).pluck(:tb_id)
        return if db_tb_ids.empty?

        unsigned_cs_tb_ids = db_tb_ids - lms_tb_ids
        return if unsigned_cs_tb_ids.empty?

        delete_all_by(tb_id: unsigned_cs_tb_ids, account_id: current_account.id)
      end

      def delete_all_by(options)
        appshell.user.documents.where(options).destroy_all
      end

      def lms_load
        @lms_info = call_data { appshell.authsession.load_documents }
      end
    end
  end
end
