# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    class FileController
      class VideoNote < Teachbase::Bot::FileController
        def initialize(params)
          @type = "video_note"
          super(params)
        end

        def source
          context.message.video_note
        end
      end
    end
  end
end
