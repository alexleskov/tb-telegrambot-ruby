require './lib/answers/answer'

class Teachbase::Bot::AnswerText < Teachbase::Bot::Answer
  def initialize(appshell, param)
    super(appshell, param)
  end

  def create(options)
    super(options)
    raise "Option 'text' is missing" unless options[:text]
    
    MessageSender.new(msg_params).send
  end

  def send_out(text, disable_notification = false)
    create(text: text, disable_notification: disable_notification)
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
  
  def ask_login
    send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:"
  end

  def ask_password
    send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
  end

end
