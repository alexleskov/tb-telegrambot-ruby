require 'active_record'

module Teachbase
  module Bot
    class Setting < ActiveRecord::Base
      belongs_to :tg_account, dependent: :destroy
      
    end
  end
end
