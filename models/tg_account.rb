# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class TgAccount < ActiveRecord::Base
      include Decorators::TgAccount

      has_one :setting, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :users, through: :auth_sessions
      has_many :bot_messages, dependent: :destroy
      has_many :tg_account_messages, dependent: :destroy
      has_many :cache_messages, dependent: :destroy

      def last_active_auth_session
        auth_sessions.where(active: true).order(auth_at: :desc).first
      end

      def on_taking_data?
        reload.context_state == Teachbase::Bot::Controller::TAKING_DATA_CONTEXT_STATE
      end
    end
  end
end
