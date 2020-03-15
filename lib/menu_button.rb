class MenuButton
  BUTTON_TYPES = %i[inline_cb inline_nums inline_back inline_more inline_url text_command].freeze

  class << self
    def t(button_type, options)
      new(button_type, options).create_button
    end
  end

  attr_reader :button_type,
              :command_prefix,
              :buttons_sign,
              :sent_messages,
              :text,
              :limit,
              :offset,
              :url,
              :callback,
              :commands,
              :callbacks_data,
              :back_button,
              :i18n

  def initialize(button_type, options)
    @logger = AppConfigurator.new.get_logger
    @button_type = button_type
    @buttons_sign = options[:buttons_sign]
    @sent_messages = options[:sent_messages]
    @commands = options[:commands]
    @text = options[:text]
    @limit = options[:limit]
    @offset = options[:offset]
    @url = options[:url]
    @callbacks_data = options[:callbacks_data]
    @command_prefix = options[:command_prefix] || ""
    @i18n = options[:i18n] || :translate
    @back_button ||= options[:back_button]
  end

  def create_button
    if self.respond_to?(button_type)
      @menu_buttons = self.public_send(button_type)
      inline_back if back_button
      @menu_buttons
    else
      raise "No such button type: '#{button_type}'. Avaliable: '#{BUTTON_TYPES}'"
    end
  end

  def inline_cb(buttons_name = buttons_sign)
    raise "Expected an Array for buttons names. You gave #{buttons_name.class}" unless buttons_name.is_a?(Array)

    buttons = []
    @callbacks_data ||= buttons_name
    find_callback(:cb_for_inline_cb_button)
    buttons_name.each_with_index do |button_name, ind|
      text_on_button = text || button_name
      text_on_button = I18n.t(text_on_button.to_s) if i18n == :translate
      buttons << [text: text_on_button, callback_data: "#{callback[ind]}"]
    end
    buttons
  end

  def text_command
    raise unless commands

    buttons = []
    buttons_sign.each { |button_sign| buttons << commands.show(button_sign) }
    buttons
  end

  def inline_url
    [ text: "#{text}",
      url: url ]
  end

  def inline_nums
    buttons_num = give_indexes(buttons_sign)
    inline_cb(buttons_num)
  end

  def inline_back
    find_callback(:cb_for_back_button)
    return unless callback

    @menu_buttons ||= []
    @menu_buttons << [text: "#{Emoji.t(:arrow_left)} #{I18n.t('back')}", callback_data: callback]
  end

  def inline_more
    find_callback(:cb_for_more_button)

    [[ text: "#{Emoji.t(:arrow_double_down)} #{I18n.t('show_more')}",
      callback_data: callback ]]
  end

  def find_callback(cb_type)
    @callback = self.public_send(cb_type) if self.respond_to?(cb_type)
    return unless callback
  end

  def give_indexes(array)
    raise "Expected an Array. Given '#{array.class}'" unless array.is_a?(Array)

    indexes = []
    array.each_with_index { |item, i| indexes << i.to_s }
    indexes
  end

  def cb_for_inline_cb_button
    raise "Expected an Array for buttons names. You gave #{callbacks_data.class}" unless callbacks_data.is_a?(Array)
    
    result = []
    callbacks_data.each do |callback_data|
      result << "#{command_prefix}#{callback_data}"
    end
    result
  end

  def cb_for_more_button
    "#{command_prefix}_lim:#{limit}_offset:#{offset}"
  end

  def cb_for_back_button
    raise unless sent_messages

    callbacks = sent_messages.order(created_at: :desc).where(message_type: "callback_data")
                            .select(:data)
    raise "Can't find callbacks for back button" unless callbacks

    result = callbacks.each_with_index do |clb, ind|
                return unless callbacks[ind + 1]

                break callbacks[ind + 1] if callbacks[ind + 1].data != clb.data
              end
    result.data if result
  end
end
