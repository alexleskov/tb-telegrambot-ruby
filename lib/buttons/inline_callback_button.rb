# frozen_string_literal: true

require './lib/buttons/menu_button'

class InlineCallbackButton < MenuButton
  class << self
    def g(options)
      super(:callback_data, options)
    end

    def nums
      g(buttons_sign: give_indexes(buttons_sign))
    end

    def back(sent_messages)
      return unless last_unical_callback(sent_messages)

      g(callback_data: [last_unical_callback(sent_messages)],
        buttons_sign: [I18n.t('back').to_s],
        emoji: [:arrow_left])
    end

    def custom_back(callback_data)
      g(buttons_sign: [I18n.t('back')], callback_data: [callback_data], emoji: [:arrow_left])
    end

    def more(options)
      raise unless options[:limit] || options[:offset]

      g(callback_data: ["#{options[:command_prefix]}_lim:#{options[:limit]}_offset:#{options[:offset]}"],
        buttons_sign: [I18n.t('show_more').to_s], emoji: [:arrow_down])
    end

    def sign_in
      g(callback_data: ["signin"], buttons_sign: [I18n.t('signin').to_s], emoji: [:rocket])
    end

    private

    def last_unical_callback(sent_messages)
      raise unless sent_messages

      callbacks = sent_messages.order(created_at: :desc).where(message_type: "callback_data") # TODO: Add limit
                               .select(:data)
      raise "Can't find callbacks for back button" unless callbacks

      result = callbacks.each_with_index do |clb, ind|
        break unless callbacks[ind + 1]
        break callbacks[ind + 1] if callbacks[ind + 1].data != clb.data
      end
      result&.data
    end
  end

  def find_params
    params = super
    return unless params

    create_callbacks(params)
  end

  private

  def create_callbacks(params)
    return unless params
    raise "Expected an Array for buttons names. You gave #{params.class}" unless params.is_a?(Array)

    result = []
    params.each do |param|
      result << "#{command_prefix}#{param}"
    end
    result
  end

  def give_indexes(array)
    raise "Expected an Array. Given '#{array.class}'" unless array.is_a?(Array)

    indexes = []
    array.each_with_index { |_item, i| indexes << i.to_s }
    indexes
  end
end
