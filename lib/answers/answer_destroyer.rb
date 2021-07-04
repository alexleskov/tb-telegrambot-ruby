# frozen_string_literal: true

class Teachbase::Bot::AnswerDestroyer < Teachbase::Bot::AnswerController
  attr_reader :delete_mode, :message_on_delete, :message_id

  def create(options)
    @message_type = options[:delete_bot_message][:type]
    @delete_mode = options[:delete_bot_message][:mode]
    @message_on_delete = find_message_on_delete
    super(options)
    @message_id = find_message_id
    self
  end

  def push
    MessageSender.new(self).destroy
  end

  private

  def find_chat_id
    message_on_delete.chat_id
  end

  def find_message_id
    message_on_delete.message_id
  end

  def find_message_on_delete
    bot_messages_on_delete = message_type ? bot_messages.where.not(message_type => nil) : bot_messages
    case delete_mode
    when :last
      bot_messages_on_delete.last_sent
    when :previous
      bot_messages_on_delete.previous_sent
    end
  end
end