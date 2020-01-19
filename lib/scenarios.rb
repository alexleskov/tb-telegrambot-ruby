require './lib/scenarios/base.rb'
require './lib/scenarios/standart_learning.rb'
require './lib/scenarios/marathon.rb'

module Teachbase
  module Bot
    module Scenarios
      LIST = %w[Base StandartLearning Marathon].freeze
    end
  end
end
