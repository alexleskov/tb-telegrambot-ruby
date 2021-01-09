# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    class FileController
      class Video < Teachbase::Bot::FileController
        def initialize(params)
          @type = "video"
          super(params)
        end

        def source
          context.message.video
        end
      end
    end
  end
end
