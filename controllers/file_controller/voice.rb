# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    module FileController
      class Voice
        def initialize(params)
          @type = "voice"
          super(params)
        end

        def file
          message.voice
        end
      end
    end
  end
end
