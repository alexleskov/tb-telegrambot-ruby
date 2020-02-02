require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :from)
    save_message
  end
  
  private

  def on(command, &block)
    super(command, :data, &block)
  end

  def save_message(result_data = {})
    result_data = { data: @message.data,
                    message_type: "callback_data"}
    super(result_data)
  end
end
