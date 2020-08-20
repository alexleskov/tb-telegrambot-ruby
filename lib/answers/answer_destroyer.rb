# frozen_string_literal: true

class Teachbase::Bot::AnswerDestroyer < Teachbase::Bot::AnswerController
  def create(options)
    super(options)
    MessageSender.new(msg_params).destroy
  end
end
