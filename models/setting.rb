require 'active_record'

module Teachbase
  module Bot
    class Setting < ActiveRecord::Base
      belongs_to :tg_account, dependent: :destroy
      PARAMS = %i[localization scenario].freeze
    end
  end
end
