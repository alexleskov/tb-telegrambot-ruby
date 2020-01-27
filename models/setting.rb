require 'active_record'

module Teachbase
  module Bot
    class Setting < ActiveRecord::Base
      belongs_to :tg_account
      
      PARAMS = %i[localization scenario].freeze
      LOCALIZATION_PARAMS = %i[ru en].freeze
      SCENARIO_PARAMS = %i[standart_learning marathon].freeze
    end
  end
end
