require 'active_record'

module Teachbase
  module Bot
    class BotMessage < ActiveRecord::Base
      has_one :tg_account, dependent: :destroy
    end
  end
end
