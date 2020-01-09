require 'active_record'

module Teachbase
  module Bot
    class ApiToken < ActiveRecord::Base
      has_many :auth_sessions, dependent: :destroy

      def avaliable?
        return if value.nil? || value.empty? || !active
        
        self.active = expired_at >= Time.now.utc
        save
        active
      end

    end
  end
end
