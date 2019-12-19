require './lib/tbclient/client'

require 'active_record'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      belongs_to :tg_account
      has_many :auth_sessions

    end
  end
end
