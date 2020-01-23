require './lib/answers/answer'

class Teachbase::Bot::AnswerText < Teachbase::Bot::Answer
  def initialize(appshell, param)
    super(appshell, param)
  end

  def create(options)
    super(options)
    msg_params = { bot: @respond.incoming_data.bot,
                   chat: destination,
                   text: text }
    MessageSender.new(msg_params).send
  end

  def send_out(text)
    create(text: text)
  end

  def send_out_greeting_message
    send_out("#{I18n.t('greeting_message')} <b>#{user_fullname(:string)}!</b>")
  end

  def send_out_farewell_message
    send_out("#{I18n.t('farewell_message')} <b>#{user_fullname(:string)}!</b>")
  end

  def if_empty_msg
    send_out "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
  end
end
