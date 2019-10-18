require 'active_record'

module Teachbase
  module Bot
    class ApiToken < ActiveRecord::Base
      belongs_to :users, dependent: :destroy

      def active?
        return if value.nil? || value.empty?
        result = expired_at >= Time.now.utc
        active = result
        save
      end
    end
  end
end
