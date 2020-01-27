require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :from)
  end
  
  private

  def on(command, &block)
    super(command, :data, &block)
  end
end
