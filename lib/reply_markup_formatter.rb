# frozen_string_literal: true

class ReplyMarkupFormatter
  attr_reader :array

  def initialize(options = {})
    @array = options[:buttons]
    @slices = !options[:slices].nil? ? options[:slices] : 1
  end

  def build_markup
    Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: build_buttons(Telegram::Bot::Types::KeyboardButton).each_slice(@slices).to_a, one_time_keyboard: false)
  end

  def build_inline_markup
    Telegram::Bot::Types::InlineKeyboardMarkup
      .new(inline_keyboard: build_buttons(Telegram::Bot::Types::InlineKeyboardButton).each_slice(@slices).to_a)
  end

  private

  def build_buttons(button_class)
    return unless array

    buttons = []
    array.each do |button|
      buttons << button_class.new(button)
    end
    buttons
  end

end
