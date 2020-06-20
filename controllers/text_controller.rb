# frozen_string_literal: true

require './controllers/controller'

class Teachbase::Bot::TextController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :chat)
  end

  def text
    message.text
  end

  def save_message(mode)
    @message_params = { text: message.text, message_type: "text" }
    super(mode)
  end

  private

  def on(command, &block)
    action = super(command, :text, &block)
    self unless action
  end
end
