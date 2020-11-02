# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Setting < ActiveRecord::Base
      belongs_to :tg_account

      PARAMS = %i[localization].freeze
      # TODO: Get it back after update scenarios logics
      # PARAMS = %i[localization scenario].freeze
      LOCALIZATION_PARAMS = %i[ru en].freeze
      LOCALIZATION_EMOJI = %i[ru us].freeze
      SCENARIO_PARAMS = %i[standart_learning marathon battle].freeze
      SCENARIO_EMOJI = %i[books bicyclist trophy].freeze
    end
  end
end
