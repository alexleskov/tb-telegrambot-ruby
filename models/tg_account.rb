require 'active_record'

module Teachbase
  module Bot
    class TgAccount < ActiveRecord::Base
      has_one :setting, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :users, through: :auth_sessions
    end
  end
end
