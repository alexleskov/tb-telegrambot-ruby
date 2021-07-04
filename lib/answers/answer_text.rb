# frozen_string_literal: true

class Teachbase::Bot::AnswerText < Teachbase::Bot::AnswerController
  def create(options)
    @message_type = :text
    super(options)
    raise "Option 'text' is missing" unless text

    self
  end

  def send_out(options)
    create(options)
  end

  def send_to(tg_id, text)
    create(text: text, reply_to_tg_id: tg_id)
  end
end
