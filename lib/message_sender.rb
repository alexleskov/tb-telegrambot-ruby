# frozen_string_literal: true

require './lib/reply_markup_formatter'

class MessageSender
  MSG_TYPES = %i[photo video document audio menu].freeze

  attr_reader :bot,
              :msg_data,
              :msg_type,
              :chat_id,
              :reply_to_tg_id,
              :reply_to_message_id,
              :parse_mode,
              :disable_notification,
              :disable_web_page_preview,
              :delete_bot_message,
              :bot_messages,
              :caption,
              :mode,
              :text,
              :menu_data,
              :menu_type

  def initialize(msg_params)
    @bot = msg_params[:bot]
    @chat_id = msg_params[:chat_id]
    @tg_user = msg_params[:tg_user]
    @bot_messages = @tg_user.bot_messages
    @text = msg_params[:text]
    @menu_type = msg_params[:menu]
    @parse_mode = msg_params[:parse_mode] || $app_config.load_parse_mode
    @disable_notification = msg_params[:disable_notification] || false
    @disable_web_page_preview = msg_params[:disable_web_page_preview] || false
    @reply_to_message_id = msg_params[:reply_to_message_id]
    @reply_to_tg_id = msg_params[:reply_to_tg_id]
    @menu_data = msg_params[:menu_data]
    @delete_bot_message = msg_params[:delete_bot_message]
    @caption = msg_params[:caption]
    @mode = msg_params[:mode] || find_menu_mode
    @msg_type = find_msg_type(msg_params)
    @msg_data = find_msg_data(msg_params)
  end

  def send
    msg_type_sign = msg_type == :menu ? :reply_markup : msg_type
    params = { text: text, msg_type_sign => msg_data }
    params[:parse_mode] = parse_mode
    params[:disable_notification] = disable_notification
    params[:disable_web_page_preview] = disable_web_page_preview
    params[:chat_id] = @chat_id
    params[:reply_to_message_id] = reply_to_message_id if reply_to_message_id
    params[:caption] = caption if caption
    sending_message = create_message(params)
    save_message(sending_message["result"])
  end

  def destroy
    return if delete_bot_message.nil? || bot_messages.empty?

    msg_on_destroy = find_msg_on_destroy
    return if @tg_user.id.to_i != msg_on_destroy.chat_id.to_i # Messages deletion only for current tg user

    bot.api.delete_message(message_id: msg_on_destroy.message_id, chat_id: msg_on_destroy.chat_id)
  end

  private

  def find_msg_on_destroy
    msg = delete_bot_message[:type] ? bot_messages.where.not(delete_bot_message[:type] => nil) : bot_messages
    case delete_bot_message[:mode]
    when :last
      msg.last_sended
    when :previous
      msg.previous_sended
    end
  end

  def find_menu_mode
    menu_type == :menu_inline && mode != :none ? :edit_msg : :none
  end

  def find_msg_data(msg_params)
    msg_type == :menu ? create_menu : msg_params[msg_type]
  end

  def find_msg_type(msg_params)
    type = MSG_TYPES.each do |type_of_msg|
      break type_of_msg if msg_params.keys.include?(type_of_msg)
    end
    type.is_a?(Symbol) ? type : :text
  end

  def same_inline_keyboard?(result)
    return unless result["reply_markup"] && bot_messages.last_sended

    result["reply_markup"]["inline_keyboard"] == bot_messages.last_sended.reply_markup
  end

  def save_message(result)
    return if same_inline_keyboard?(result) || !@tg_user
    return unless %i[text menu].include?(msg_type.to_sym)

    bot_messages.create!(fetch_msg_result_data(result))
  end

  def create_menu
    case menu_type
    when :menu_inline
      inline_markup
    when :menu
      reply_markup
    when :hide_kb
      hide_markup
    when :force_reply
      force_reply_markup
    else
      raise "Can't find menu type. Given: '#{menu_type}'"
    end
  end

  def create_message(params)
    case mode
    when :edit_msg
      return send_msg_by_type(params) unless bot_messages.last_sended

      params[:message_id] = bot_messages.last_sended.message_id
      if %i[text menu].include?(msg_type)
        bot.api.edit_message_text(params)
      else
        bot.api.edit_message_media(params)
      end
    else
      send_msg_by_type(params)
    end
  end

  def send_msg_by_type(params)
    case msg_type
    when :menu, :text
      bot.api.send_message(params)
    when :photo
      bot.api.send_photo(params)
    when :video
      bot.api.send_video(params)
    when :document
      bot.api.send_document(params)
    when :audio
      bot.api.send_audio(params)
    else
      raise "Can't find such message type for sending: '#{msg_type}'. Avaliable: '#{MSG_TYPES}'"
    end
  end

  def reply_markup
    ReplyMarkupFormatter.new(menu_data).build_markup
  end

  def hide_markup
    Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  end

  def inline_markup
    ReplyMarkupFormatter.new(menu_data).build_inline_markup
  end

  def force_reply_markup
    Telegram::Bot::Types::ForceReply.new(force_reply: true)
  end

  def fetch_msg_result_data(result)
    { message_id: result["message_id"],
      chat_id: result["chat"]["id"],
      date: result["date"],
      edit_date: result["edit_date"],
      text: result["text"],
      reply_markup: result["reply_markup"] }
  end
end
