# frozen_string_literal: true

require './lib/buttons/button'

class InlineCallbackButton < Button
  ACTION_TYPE = :callback_data

  class << self
    def g(options)
      super(:callback_data, options)
    end

    def back(sent_messages)
      return unless last_unical_callback(sent_messages)

      g({ callback_data: last_unical_callback(sent_messages) }.merge!(back_button_default_params))
    end

    def custom_back(callback_data)
      g({ callback_data: callback_data }.merge!(back_button_default_params))
    end

    def more(options)
      raise unless options[:callback_data]

      g(callback_data: "#{options[:callback_data]}", button_sign: I18n.t('show_more').to_s,
        emoji: :arrow_down)
    end

    def sign_in(callback_data)
      g(callback_data: callback_data, button_sign: I18n.t('sign_in').to_s, emoji: :rocket)
    end

    private

    def back_button_default_params
      { button_sign: I18n.t('back').to_s, emoji: :arrow_left }
    end

    def last_unical_callback(sent_messages)
      raise unless sent_messages

      callbacks = sent_messages.order(created_at: :desc).where(message_type: "callback_data").limit(5)
                               .select(:data)
      return if callbacks.empty?

      result = callbacks.each_with_index do |clb, ind|
        break unless callbacks[ind + 1]
        break callbacks[ind + 1] if callbacks[ind + 1].data != clb.data
      end
      result&.data
    end
  end

  def find_param
    param = super
    create_callback(param)
  end

  private

  def create_callback(param)
    return unless param

    "#{command_prefix}#{param}"
  end
end
