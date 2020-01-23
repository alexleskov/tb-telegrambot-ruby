require './lib/reply_markup_formatter'
require './lib/app_configurator'

class MessageSender
  attr_reader :bot, :text, :chat, :reply_to_message_id, :menu, :menu_inline

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @menu = options[:menu]
    @menu_inline = options[:menu_inline]
    @parse_mode = options[:parse_mode]
    @reply_to_message_id = options[:reply_to_message_id]
    @force_reply = options[:force_reply]
    @hide_kb = options[:hide_kb]

    @logger = AppConfigurator.new.get_logger
  end

  def send
    params = { chat_id: chat.id, text: text }
    params[:reply_markup] = reply_markup unless menu.nil?
    params[:reply_to_message_id] = @reply_to_message_id if @reply_to_message_id
    params[:reply_markup] = force_reply_markup if @force_reply
    params[:reply_markup] = hide_markup if @hide_kb
    params[:reply_markup] = inline_markup unless menu_inline.nil?
    params[:parse_mode] ||= AppConfigurator.new.get_parse_mode

    resp = bot.api.send_message(params)
    @logger.debug "sending '#{text}' to #{chat.username}"
  end

  private

  def reply_markup
    ReplyMarkupFormatter.new(menu).get_markup if menu.include?(:buttons)
  end

  def hide_markup
    Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  end

  def inline_markup
    ReplyMarkupFormatter.new(menu_inline).get_inline_markup if menu_inline.include?(:buttons)
  end

  def force_reply_markup
    Telegram::Bot::Types::ForceReply.new(force_reply: true)
  end
end
