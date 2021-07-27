# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class ApiToken < ActiveRecord::Base
      belongs_to :auth_session

      scope :actual, -> { where(active: true) }

      class << self
        def last_actual
          actual.order(created_at: :desc).first
        end
      end

      def avaliable?
        return if value.nil? || value.empty? || !active

        unless expired_at
          update!(active: false)
          return
        end
        update!(active: expired_at >= Time.now.utc)
        active
      end

      def activate_by(token)
        unless token.value && token.expired_at
          update!(active: false)
          raise "Can't activate token id: '#{id}'. Value: '#{token.value}', expired_at: '#{token.expired_at}'"
        end
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
