require './lib/answers/answer'

class Teachbase::Bot::AnswerText < Teachbase::Bot::Answer
  def initialize(appshell, param)
    super(appshell, param)
  end

  def create(options)
    super(options)
    MessageSender.new(msg_params).send
  end

  def send_out(text)
    create(text: text)
  end

  def greeting_message
    send_out("#{I18n.t('greeting_message')} <b>#{user_fullname(:string)}!</b>")
  end

  def farewell_message
    send_out("#{I18n.t('farewell_message')} <b>#{user_fullname(:string)}!</b>")
  end

  def empty_message
    send_out "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
  end
end
