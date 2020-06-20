# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class TgAccountMessage < ActiveRecord::Base
      has_one :tg_account
    end
  end
end
