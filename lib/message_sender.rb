require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender
  MSG_TYPES = [:text, :photo, :video, :document, :audio]

  attr_reader :bot,
              :msg_data,
              :msg_type,
              :chat,
              :reply_to_tg_id,
              :reply_to_message_id,
              :parse_mode,
              :mode,
              :menu_data,
              :menu_type

  def initialize(msg_params)
    @logger = AppConfigurator.new.get_logger
    @tg_user = msg_params[:tg_user]
    @bot = msg_params[:bot]
    @msg_type = find_msg_type(msg_params)
    @msg_data = msg_params[msg_type]
    @chat = msg_params[:chat]
    @parse_mode = msg_params[:parse_mode]
    @reply_to_message_id = msg_params[:reply_to_message_id]
    @reply_to_tg_id = msg_params[:reply_to_tg_id]
    @menu_type = msg_params[:menu_type]
    @menu_data = msg_params[:menu_data]
    @mode = msg_params[:mode] || find_menu_mode
  end

  def send
    params = {}
    params[msg_type] = msg_data
    params[:chat_id] = reply_to_tg_id || chat.id
    params[:parse_mode] = parse_mode || AppConfigurator.new.get_parse_mode
    params[:reply_to_message_id] = reply_to_message_id if reply_to_message_id
    params[:reply_markup] = create_menu if menu_type
    sending_message = create_message(params, msg_type)
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

  def find_msg_type(params)
    MSG_TYPES.each do |type_of_msg|
      break type_of_msg if params.keys.include?(type_of_msg)
    end
  end

  def last_message
    @tg_user.bot_messages.order(created_at: :desc).first
  end

  def save_message(result)
    return unless @tg_user

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
    end
  end

  def create_message(params, type)
    case mode
    when :edit_msg
      raise "Can't find last message for editing" unless last_message

      params[:message_id] = last_message.message_id

      if type == :text
        bot.api.edit_message_text(params)
      else
        bot.api.edit_message_media(params)
      end
    else
      case type
      when :text
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
        raise "Can't find such message type for sending: '#{type}'. Avaliable: '#{MSG_TYPES}'"
      end
    end    
  end

  def reply_markup
    ReplyMarkupFormatter.new(menu_data).get_markup if menu_data.include?(:buttons)
  end

  def hide_markup
    Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  end

  def inline_markup
    ReplyMarkupFormatter.new(menu_data).get_inline_markup if menu_data.include?(:buttons)
  end

  def force_reply_markup
    Telegram::Bot::Types::ForceReply.new(force_reply: true)
  end

  private

  def fetch_msg_result_data(result)
    { message_id: result["message_id"],
                        chat_id: result["chat"]["id"],
                        date: result["date"],
                        edit_date: result["edit_date"],
                        text: result["text"],
                        inline_keyboard: result["reply_markup"]["inline_keyboard"] }
  end
end
