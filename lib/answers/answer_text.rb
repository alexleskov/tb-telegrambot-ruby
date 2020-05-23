# frozen_string_literal: true

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

  def empty_message(title = "")
    send_out "#{title}#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
  end

  def error
    send_out "#{Emoji.t(:boom)} <i>#{I18n.t('unexpected_error')}</i>"
  end

  def declined
    send_out "#{Emoji.t(:leftwards_arrow_with_hook)} <i>#{I18n.t('declined')}</i>"
  end

  def accepted
    send_out "#{Emoji.t(:ok)} <i>#{I18n.t('accepted')}</i>"
  end

  def ask_answer
    send_out "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_answer')}:"
  end

  def ask_login
    send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:"
  end

  def ask_password
    send_out "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
  end
end
