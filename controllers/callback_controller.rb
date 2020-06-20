# frozen_string_literal: true

require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :from)
    save_message
  end

  def save_message
    @message_params = { data: message.data, message_type: "callback_data" }
    super(:perm)
  end

  private

  def on(command, &block)
    super(command, :data, &block)
  end
end
