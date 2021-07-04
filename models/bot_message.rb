# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class BotMessage < ActiveRecord::Base
      has_one :tg_account, dependent: :destroy

      class << self
        def last_sent
          order(created_at: :desc).first
        end

        def previous_sent
          order(created_at: :desc).second
        end
      end
    end
  end
end
