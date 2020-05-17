# frozen_string_literal: true

require './controllers/controller'

class Teachbase::Bot::ActionController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :chat)
  end

  private

  def on(command, &block)
    super(command, :text, &block)
  end
end
