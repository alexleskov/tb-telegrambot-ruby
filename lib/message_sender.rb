# frozen_string_literal: true

require './lib/reply_markup_formatter'

class MessageSender
  MSG_TYPES = %i[photo video document audio menu].freeze

  attr_reader :bot,
              :msg_data,
              :msg_type,
              :chat,
              :reply_to_tg_id,
              :reply_to_message_id,
              :parse_mode,
              :disable_notification,
              :disable_web_page_preview,
              :mode,
              :text,
              :menu_data,
              :menu_type

  def initialize(msg_params)
    @logger = AppConfigurator.new.load_logger
    @bot = msg_params[:bot]
    @chat = msg_params[:chat]
    @tg_user = msg_params[:tg_user]
    @text = msg_params[:text]
    @menu_type = msg_params[:menu]
    @parse_mode = msg_params[:parse_mode] || AppConfigurator.new.load_parse_mode
    @disable_notification = msg_params[:disable_notification] || false
    @disable_web_page_preview = msg_params[:disable_web_page_preview] || false
    @reply_to_message_id = msg_params[:reply_to_message_id]
    @reply_to_tg_id = msg_params[:reply_to_tg_id]
    @menu_data = msg_params[:menu_data]
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
    params[:chat_id] = reply_to_tg_id || chat.id
    params[:reply_to_message_id] = reply_to_message_id if reply_to_message_id
    sending_message = create_message(params)
    save_message(sending_message["result"]) if sending_message["result"]["reply_markup"]
  end

  private

  def find_menu_mode
    if menu_type == :menu_inline && mode != :none
      :edit_msg
    else
      :none
    end
  end

  def find_msg_data(msg_params)
    if msg_type == :menu
      create_menu
    else
      msg_params[msg_type]
    end
  end

  def find_msg_type(msg_params)
    type = MSG_TYPES.each do |type_of_msg|
      break type_of_msg if msg_params.keys.include?(type_of_msg)
    end
    type = :text unless type.is_a?(Symbol)
    type
  end

  def last_message
    @tg_user.bot_messages.order(created_at: :desc).first
  end

  def same_inline_keyboard?(result)
    return unless last_message

    result["reply_markup"]["inline_keyboard"] == last_message.inline_keyboard
  end

  def save_message(result)
    return if same_inline_keyboard?(result) && !@tg_user

    @tg_user.bot_messages.create!(fetch_msg_result_data(result))
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
      raise "Can't find last message for editing" unless last_message

      params[:message_id] = last_message.message_id
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
    ReplyMarkupFormatter.new(menu_data).build_markup if menu_data.include?(:buttons)
  end

  def hide_markup
    Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  end

  def inline_markup
    ReplyMarkupFormatter.new(menu_data).build_inline_markup if menu_data.include?(:buttons)
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
      inline_keyboard: result["reply_markup"]["inline_keyboard"] }
  end
end
