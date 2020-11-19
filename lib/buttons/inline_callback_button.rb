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

    def custom_back(callback_data, button_params = {})
      button_params =
        if button_params[:button_sign] && button_params[:emoji]
          button_params
        else
          back_button_default_params
        end
      g({ callback_data: callback_data }.merge!(button_params))
    end

    def more(options)
      raise unless options[:callback_data]

      options[:button_sign] ||= I18n.t('show_more').to_s
      options[:emoji] ||= :arrow_right
      options[:action_type] = :more
      g(options)
    end

    def less(options)
      raise unless options[:callback_data]

      options[:button_sign] ||= I18n.t('show_less').to_s
      options[:emoji] ||= :arrow_left
      options[:action_type] = :less
      g(options)
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

      msg_with_callbacks = sent_messages.where(message_type: "callback_data")
      msg_with_callbacks.order(created_at: :asc).limit(5).destroy_all if msg_with_callbacks.all.size >= 10
      callbacks = msg_with_callbacks.limit(5).order(created_at: :desc).select(:data)
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

  def create_callback(param)
    return unless param

    "#{command_prefix}#{param}"
  end
end
