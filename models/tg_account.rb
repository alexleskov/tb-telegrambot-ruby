require 'active_record'

module Teachbase
  module Bot
    class TgAccount < ActiveRecord::Base
      has_many :users

    end
  end
end
