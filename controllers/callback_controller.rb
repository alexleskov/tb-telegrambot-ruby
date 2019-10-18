require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller

  attr_reader :user, :message_responder, :answer, :menu

  def initialize(message_responder)
    super(message_responder, :from)
  end

  def match_data
    case message_responder.message.data
    when 'touch'
      answer.send "Touch this"
    end
  end

end
