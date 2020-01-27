require './lib/scenarios/base.rb'
require './lib/scenarios/standart_learning.rb'
require './lib/scenarios/marathon.rb'

module Teachbase
  module Bot
    module Scenarios
      LIST = %w[base standart_learning marathon].freeze
    end
  end
end
