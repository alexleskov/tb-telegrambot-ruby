# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class CacheMessage < ActiveRecord::Base
      DELIMETER = " "
      has_one :tg_account

      class << self
        def texts
          result = []
          where(message_type: "text").select(:data).each do |cache_message|
            result << cache_message.data
          end
          result.join(DELIMETER)
        end

        def files_ids
          result = []
          where(message_type: "file").select(:file_id).each do |cache_message|
            result << cache_message.file_id
          end
          result
        end

        def raise_last_message_by(tg_account)
          last_created = where(tg_account_id: tg_account.id).order(created_at: :desc).first
          source_name = last_created.file_type || last_created.message_type
          result = OpenStruct.new(source_name => build_source_data(last_created.data, :entity),
                                  message_id: last_created.message_id, tg_account: tg_account)
          last_created.destroy
          result
        end

        private

        def build_source_data(data, mode)
          return data if data.is_a?(String) || mode == :plain

          OpenStruct.new(data)
        end
      end
    end
  end
end
