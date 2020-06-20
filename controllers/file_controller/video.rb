# frozen_string_literal: true

require './controllers/file_controller'

class Teachbase::Bot::FileController::Video < Teachbase::Bot::FileController
  def initialize(params)
    @type = "video"
    super(params)
  end

  def file
    message.video
  end
end
