# frozen_string_literal: true

class ReplyMarkupFormatter
  attr_reader :array

  def initialize(options = {})
    @array = options[:buttons]
    @slices = !options[:slices].nil? ? options[:slices] : 1
  end

  def build_markup
    Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: array.each_slice(@slices).to_a, one_time_keyboard: true)
  end

  def build_inline_markup
    buttons = []
    array.each do |button|
      buttons << Telegram::Bot::Types::InlineKeyboardButton.new(button.first)
    end
    Telegram::Bot::Types::InlineKeyboardMarkup
      .new(inline_keyboard: buttons.each_slice(@slices).to_a)
  end
end
