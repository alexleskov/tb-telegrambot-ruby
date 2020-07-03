# frozen_string_literal: true

require './controllers/file_controller'

module Teachbase
  module Bot
    module FileController
      class Document < Teachbase::Bot::FileController
        def initialize(params)
          @type = "document"
          super(params)
        end

        def file
          message.document
        end
      end
    end
  end
end
