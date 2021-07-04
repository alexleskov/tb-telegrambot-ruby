# frozen_string_literal: true

class MessageSender
  attr_reader :message, :on_send_params, :sent_message

  def initialize(answer_controller)
    @message = answer_controller
    raise unless answer_controller.is_a?(Teachbase::Bot::AnswerController)

    @on_send_params = prepare_on_send_params
  end

  def send_now
    @sent_message =
      if message.mode == :edit_msg && message.bot_messages.last_sent
        send_with_edit_mode
      else
        send_normal
      end
    save_result if sent_message
  end

  def destroy
    return if (message.message_id.nil? || message.bot_messages.empty?) || (message.tg_user.id.to_i != message.chat_id.to_i) # Messages deletion only for current tg user

    message.bot.api.delete_message(message_id: message.message_id, chat_id: message.chat_id)
  end

  private

  def prepare_on_send_params
    message.instance_variables.each_with_object({}) do |var, hash| # Parsing instance variables of message into hash
      hash[var.to_s.delete("@")] = message.instance_variable_get(var)
    end
  end

  def send_normal
    if message.respond_to?(:content_type) && message.content_type
      @on_send_params[message.content_type.to_s] = message.file
      send_by_content_type
    else
      message.bot.api.send_message(on_send_params)
    end
  end

  def send_with_edit_mode
    @on_send_params["message_id"] = message.bot_messages.last_sent.message_id
    if message.respond_to?(:content_type) && message.content_type
      @on_send_params[message.content_type.to_s] = message.file
      message.bot.api.edit_message_media(on_send_params)
    else
      message.bot.api.edit_message_text(on_send_params)
    end
  end

  def send_by_content_type
    case message.content_type
    when :photo
      message.bot.api.send_photo(on_send_params)
    when :video
      message.bot.api.send_video(on_send_params)
    when :document
      message.bot.api.send_document(on_send_params)
    when :audio
      message.bot.api.send_audio(on_send_params)
    end
  end

  def same_inline_keyboard?(fetched_reply_markup)
    return unless fetched_reply_markup && message.bot_messages.last_sent

    fetched_reply_markup["inline_keyboard"] == message.bot_messages.last_sent.reply_markup
  end

  def save_result
    fetched_result = fetch_sent_result(sent_message["result"])
    raise "Not any result to save with sent_message: '#{sent_message}'" unless sent_message["result"]
    return if same_inline_keyboard?(fetched_result[:reply_markup] || !message.tg_user) || !%i[text reply_markup].include?(message.message_type.to_sym)

    message.bot_messages.create!(fetched_result)
  end

  def fetch_sent_result(sent_result)
    { message_id: sent_result["message_id"],
      chat_id: sent_result["chat"]["id"],
      date: sent_result["date"],
      edit_date: sent_result["edit_date"],
      text: sent_result["text"],
      reply_markup: sent_result["reply_markup"] }
  end
end
