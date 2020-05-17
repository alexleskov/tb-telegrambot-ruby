# frozen_string_literal: true

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

      def activate_by(token)
        update!(version: token.api_version,
                api_type: token.api_type,
                grant_type: token.grant_type,
                expired_at: token.expired_at,
                value: token.value,
                active: true)
      end
    end
  end
end
