# frozen_string_literal: true

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

  def save_message(_result_data = {})
    result = { data: @message.data, message_type: "callback_data" }
    super(result)
  end
end
