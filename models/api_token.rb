require 'active_record'

module Teachbase
  module Bot
    class ApiToken < ActiveRecord::Base
      belongs_to :users, dependent: :destroy

      def avaliable?
        return if value.nil? || value.empty?
        self.active = expired_at >= Time.now.utc
        save
        active
      end

    end
  end
end
