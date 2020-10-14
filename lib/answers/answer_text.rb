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

  def empty_message(title = "")
    send_out "#{title}#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
  end

  def undefined_action
    send_out "#{Emoji.t(:baby)} <i>#{I18n.t('undefined_action')}</i>"
  end

  def error
    send_out "#{Emoji.t(:boom)} <i>#{I18n.t('unexpected_error')}</i>"
  end

  def accepted
    send_out "#{Emoji.t(:ok)} <i>#{I18n.t('accepted')}</i>"
  end

  def ask_answer(text = "")
    send_out "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_answer')}:\n#{text}"
  end
end
