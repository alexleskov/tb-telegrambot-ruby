# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    class FileController
      class Voice < Teachbase::Bot::FileController
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
