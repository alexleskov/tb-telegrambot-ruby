require './viewers/viewers.rb'
require './lib/scenarios/base.rb'
require './lib/scenarios/standart_learning.rb'
require './lib/scenarios/marathon.rb'

module Teachbase
  module Bot
    module Scenarios
      LIST = %w[standart_learning marathon battle].freeze
    end
  end
end
