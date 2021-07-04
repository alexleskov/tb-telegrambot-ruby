# frozen_string_literal: true

require './lib/reply_markup_formatter'
require './lib/keyboards/text_command_keyboard'
require './lib/keyboards/inline_callback_keyboard'
require './lib/keyboards/inline_url_keyboard'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::AnswerController
  MENU_TYPES = %i[menu menu_inline hide_kb force_reply].freeze

  attr_reader :menu_type, :slices_count, :buttons, :reply_markup

  def create(options)
    @message_type = :reply_markup
    super(options)
    @menu_type = options[:type]
    raise "No such menu type: #{menu_type}" unless MENU_TYPES.include?(menu_type)

    @buttons = options[:buttons]
    @slices_count = options[:slices_count] || nil
    @reply_markup = !%i[hide_kb force_reply].include?(menu_type) ? build_reply_markup : nil
    @mode = options[:mode]
    unless mode
      menu_type == :menu_inline ? :edit_msg : :none
    end
    self
  end

  def hide(options)
    create(text: options[:text], type: :hide_kb)
  end

  def force_reply(options)
    create(text: options[:text], type: :force_reply)
  end

  protected

  def build_reply_markup
    case menu_type
    when :menu_inline
      build_markup(:inline)
    when :menu
      build_markup(:normal)
    when :hide_kb
      hide_markup
    when :force_reply
      force_reply_markup
    end
  end

  def build_markup(markup_type)
    raise "Buttons must be an Array class. Given '#{buttons.class}'" unless buttons.is_a?(Array)

    result = ReplyMarkupFormatter.new(buttons: buttons, slices: slices_count)
    markup_type == :inline ? result.build_inline_markup : result.build_markup
  end

  def hide_markup
    Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  end

  def force_reply_markup
    Telegram::Bot::Types::ForceReply.new(force_reply: true)
  end
end