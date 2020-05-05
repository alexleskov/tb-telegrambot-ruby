require './interfaces/interfaces'
require './lib/scenarios/base'
require './lib/scenarios/standart_learning'
require './lib/scenarios/marathon'

module Teachbase
  module Bot
    module Scenarios
      LIST = %w[standart_learning marathon battle].freeze
    end
  end
end
