# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class TgAccount < ActiveRecord::Base
      has_one :setting, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :users, through: :auth_sessions
      has_many :bot_messages, dependent: :destroy
      has_many :tg_account_messages, dependent: :destroy
      has_many :cache_messages, dependent: :destroy

      def user_fullname
        [first_name, last_name]
      end
    end
  end
end
