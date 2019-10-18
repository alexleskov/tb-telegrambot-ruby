require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller

  def initialize(message_responder)
    super(message_responder, :from)
  end

  def match_data
    case message_responder.message.data
    when "touch"
      answer.send "Touching"
    end
  end

end
