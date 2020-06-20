# frozen_string_literal: true

require './controllers/file_controller'

class Teachbase::Bot::FileController::Photo < Teachbase::Bot::FileController
  def initialize(params)
    @type = "photo"
    super(params)
  end

  def file
    message.photo.first
  end
end
