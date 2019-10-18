require 'active_record'

module Teachbase
  module Bot
    class ApiToken < ActiveRecord::Base
      belongs_to :users, dependent: :destroy
    end

      def active?
        if Time.now.utc >= token.expired_at
          token.active = false
        else
          token.active = true
        end
      end
  end
end
