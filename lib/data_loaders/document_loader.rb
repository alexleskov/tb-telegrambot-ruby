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
        lms_info.each do |document_lms|
          lms_tb_ids << @tb_id = document_lms["id"]

          update_data(document_lms.merge!("tb_id" => document_lms["id"]))
        end
        model_class.where(tb_id: lms_tb_ids, account_id: current_account)
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_documents }
      end
    end
  end
end
