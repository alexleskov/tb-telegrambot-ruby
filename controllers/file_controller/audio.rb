# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    module FileController
      class Audio < Teachbase::Bot::FileController
        def initialize(params)
          @type = "audio"
          super(params)
        end

        def file
          message.audio
        end
      end
    end
  end
end
