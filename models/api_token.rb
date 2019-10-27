require 'active_record'

module Teachbase
  module Bot
    class ApiToken < ActiveRecord::Base
      belongs_to :tg_account, dependent: :destroy
      belongs_to :user, dependent: :destroy

      def avaliable?
        return if value.nil? || value.empty?
        self.active = expired_at >= Time.now.utc
        save
        active
      end

    end
  end
end
