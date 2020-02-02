require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender

  attr_reader :bot, :text, :chat, :reply_to_message_id, :parse_mode, :mode, :menu_data, :menu_type

  def initialize(msg_params)
    @logger = AppConfigurator.new.get_logger

    @tg_user = msg_params[:tg_user]
    @bot = msg_params[:bot]
    @text = msg_params[:text]
    @chat = msg_params[:chat]
    @parse_mode = msg_params[:parse_mode]
    @reply_to_message_id = msg_params[:reply_to_message_id]
    @menu_type = msg_params[:menu_type]
    @menu_data = msg_params[:menu_data]
    @mode = msg_params[:mode]
  end

  def send
    params = { chat_id: chat.id, text: text }
    params[:parse_mode] = parse_mode || AppConfigurator.new.get_parse_mode
    params[:reply_to_message_id] = @reply_to_message_id if reply_to_message_id
    params[:reply_markup] = create_menu(menu_type)
    @mode = :edit_msg if menu_type == :menu_inline && mode != :none
    sending_message = create_message(mode, params)
    save_message(sending_message["result"]) if sending_message["result"]["reply_markup"]
  end

  private

  def last_message
    @tg_user.bot_messages.order(created_at: :desc).first
  end

  def save_message(result)
    return unless @tg_user

    result_data = { message_id: result["message_id"],
                    chat_id: result["chat"]["id"],
                    date: result["date"],
                    edit_date: result["edit_date"],
                    text: result["text"],
                    inline_keyboard: result["reply_markup"]["inline_keyboard"] }

    @tg_user.bot_messages.create!(result_data)
  end

  def create_menu(menu_type)
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

  def create_message(mode, params)
    case mode
    when :edit_msg
      raise "Can't find last message for editing" unless last_message 
      params[:message_id] = last_message.message_id
      bot.api.edit_message_text(params)
    else
      bot.api.send_message(params)
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
end
