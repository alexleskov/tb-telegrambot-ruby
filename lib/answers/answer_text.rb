# frozen_string_literal: true

class Teachbase::Bot::AnswerText < Teachbase::Bot::AnswerController
  def create(options)
    super(options)
    raise "Option 'text' is missing" unless options[:text]

    MessageSender.new(msg_params).send
  end

  def send_out(text, disable_notification = false)
    create(text: text, disable_notification: disable_notification)
  end

  def send_to(text, tg_id)
    create(text: text, reply_to_tg_id: tg_id)
  end
end
