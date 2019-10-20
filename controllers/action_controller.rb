require './controllers/controller'

class Teachbase::Bot::ActionController < Teachbase::Bot::Controller

  def initialize(message_responder)
    super(message_responder)
  end

  def match_data
    on %r{^/start} do
      answer.send_greeting_message
      menu.starting
    end

    on %r{^/close} do
      answer.send_farewell_message
    end

    on %r{^/hide_menu} do
      menu.hide
    end
  end

  private

  def on(command, &block)
    super(command, :text, &block)
  end

end
