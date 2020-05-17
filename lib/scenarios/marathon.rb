# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Marathon
        include Teachbase::Bot::Scenarios::Base

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end
      end
    end
  end
end
