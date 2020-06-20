# frozen_string_literal: true

require './controllers/file_controller'

class Teachbase::Bot::FileController::Voice < Teachbase::Bot::FileController
  def initialize(params)
    @type = "voice"
    super(params)
  end

  def file
    message.voice
  end
end
