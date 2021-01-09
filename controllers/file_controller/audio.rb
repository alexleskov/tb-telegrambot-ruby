# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    class FileController
      class Audio < Teachbase::Bot::FileController
        def initialize(params)
          @type = "audio"
          super(params)
        end

        def source
          context.message.audio
        end
      end
    end
  end
end
