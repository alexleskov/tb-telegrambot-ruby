require './lib/tbclient/client'

require 'active_record'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      has_one :profile, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :tg_accounts, through: :auth_sessions
      has_many :course_sessions, dependent: :destroy
    end
  end
end
