# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    class FileController
      class Photo < Teachbase::Bot::FileController
        def initialize(params)
          @type = "photo"
          super(params)
        end

        def source
          context.message.photo.first
        end
      end
    end
  end
end
