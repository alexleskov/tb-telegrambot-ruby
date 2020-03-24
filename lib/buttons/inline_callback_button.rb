require './lib/buttons/menu_button'

class InlineCallbackButton < MenuButton
  class << self

    attr_reader :options

    @options = {}

    def g(options)
      super(:callback_data, options)
    end

    def nums
      options[:buttons_sign] = give_indexes(buttons_sign)
      g(options)
    end

    def back(sent_messages, options = {})
      options[:callback_data] = [ last_unical_callback(sent_messages) ]
      return unless last_unical_callback(sent_messages)

      options[:buttons_sign] = [I18n.t('back').to_s]
      options[:emoji] = [Emoji.t(:arrow_left)]
      g(options)
    end

    def more(options)
      options[:limit] = limit
      options[:offset] = offset
      raise unless limit || offset

      options[:callback_data] = ["_lim:#{limit}_offset:#{offset}"]
      options[:buttons_sign] = [I18n.t('show_more').to_s]
      g(options)
    end

    def sign_in
      options[:callback_data] = ["signin"]
      options[:buttons_sign] = [I18n.t('signin').to_s]
      g(options)
    end

    def last_unical_callback(sent_messages)
      raise unless sent_messages

      callbacks = sent_messages.order(created_at: :desc).where(message_type: "callback_data") #TO DO: Add limit
                              .select(:data)
      raise "Can't find callbacks for back button" unless callbacks

      result = callbacks.each_with_index do |clb, ind|
                  return unless callbacks[ind + 1]

                  break callbacks[ind + 1] if callbacks[ind + 1].data != clb.data
                end
      result.data if result
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
    array.each_with_index { |item, i| indexes << i.to_s }
    indexes
  end
end