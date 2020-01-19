require './lib/answers/answer'

class Teachbase::Bot::AnswerText < Teachbase::Bot::Answer
  def initialize(appshell, param)
    super(appshell, param)
  end

  def send_out(text)
    raise "Can't find answer destination for message #{@respond}" if destination.nil?

    MessageSender.new(bot: @respond.incoming_data.bot, chat: destination, text: text).send
  end

  def send_out_greeting_message
    send_out("#{I18n.t('greeting_message')} <b>#{user_fullname_str}!</b>")
  end

  def send_out_farewell_message
    send_out("#{I18n.t('farewell_message')} <b>#{user_fullname_str}!</b>")
  end

  def if_empty_msg
    send_out "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
  end
end
