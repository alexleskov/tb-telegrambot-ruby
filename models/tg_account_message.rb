require 'active_record'

module Teachbase
  module Bot
    class TgAccountMessage < ActiveRecord::Base
      has_one :tg_account, dependent: :destroy
    end
  end
end
