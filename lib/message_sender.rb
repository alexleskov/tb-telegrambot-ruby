require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender

  class << self
    attr_accessor :last_msg
  end

  attr_reader :bot, :text, :chat, :reply_to_message_id, :parse_mode, :mode, :menu_data, :menu_type

  def initialize(msg_params)
    @logger = AppConfigurator.new.get_logger

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
    self.class.last_msg = create_message(mode, params)

     @logger.debug "sending '#{text}' to #{chat.username}"
     @logger.debug "last_message '#{last_message}'"
  end

  def last_message
    self.class.last_msg
  end

  private

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
      params[:message_id] = last_message["result"]["message_id"]
      msg = bot.api.edit_message_text(params)
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
