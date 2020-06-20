# frozen_string_literal: true

require './controllers/file_controller'

class Teachbase::Bot::FileController::Document < Teachbase::Bot::FileController
  def initialize(params)
    @type = "document"
    super(params)
  end

  def file
    message.document
  end
end
