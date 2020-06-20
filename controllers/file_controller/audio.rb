# frozen_string_literal: true

require './controllers/file_controller'

class Teachbase::Bot::FileController::Audio < Teachbase::Bot::FileController
  def initialize(params)
    @type = "audio"
    super(params)
  end

  def file
    message.audio
  end
end
