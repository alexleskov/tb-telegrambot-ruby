require './lib/answers/answer'

class Teachbase::Bot::AnswerText < Teachbase::Bot::Answer

  def initialize(respond, param)
    super(respond, param)
  end

  def send(text)
    raise "Can't find answer destination for message #{@respond}" if destination.nil?
    MessageSender.new(bot: @respond.incoming_data.bot, chat: destination, text: text).send
  end

  def send_greeting_message
    send("#{I18n.t('greeting_message')} <b>#{@first_name} #{@last_name}!</b>")
  end

  def send_farewell_message
    send("#{I18n.t('farewell_message')} #{@first_name} #{@last_name}!")
  end

end
