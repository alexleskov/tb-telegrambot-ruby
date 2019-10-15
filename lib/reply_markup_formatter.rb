class ReplyMarkupFormatter
  attr_reader :array

    def initialize(options={})
      @array = options[:answers]
      @slices = options[:slices].present? ? options[:slices] : 1
    end
 
    def get_markup
      Telegram::Bot::Types::ReplyKeyboardMarkup
        .new(keyboard: array.each_slice(@slices).to_a, one_time_keyboard: true)
    end
end
