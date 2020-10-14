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
          where(message_type: "text").select(:text).each do |cache_message|
            result << cache_message.text
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
      end
    end
  end
end
