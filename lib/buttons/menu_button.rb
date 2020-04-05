class MenuButton
  BUTTON_TYPES = %i[callback_data text_command url].freeze

  class << self
    def g(type, options)
      inst = new(type, options)
      buttons_list = inst.create_buttons
      back = inline_back(inst.sent_messages) if inst.back_button
      buttons_list = buttons_list + back if back
      buttons_list
    end

    def inline_back(sent_messages)
      InlineCallbackButton.back(sent_messages)
    end
  end

  attr_reader :type,
              :options,
              :command_prefix,
              :buttons_sign,
              :emoji,
              :url,
              :commands,
              :back_button,
              :sent_messages

  def initialize(type, options)
    @logger = AppConfigurator.new.get_logger
    @type = type
    @options = options
    @sent_messages = options[:sent_messages]
    @buttons_sign = options[:buttons_sign]
    @commands = options[:commands]
    @emoji = options[:emoji]
    @command_prefix = options[:command_prefix] || ""
    @back_button ||= options[:back_button]
  end

  def create_buttons
    raise unless BUTTON_TYPES.include?(type.to_sym)
    raise "Can't find buttons sign" unless buttons_sign
    raise "Expected an Array for buttons names. You gave #{buttons_sign.class}" unless buttons_sign.is_a?(Array)

    buttons = []
    type_params = find_params
    return unless type_params

    buttons_sign.each_with_index do |button_sign, ind|
      buttons << init_button(button_sign, type_params, ind)
    end
    buttons
  end

  protected

  def find_params
    options[type.to_sym] || buttons_sign
  end

  def init_button(button_sign, type_params, ind)
    [ create_button_name(button_sign, ind).merge(create_action(type_params, ind)) ]
  end

  def create_action(type_params, ind)
    { type.to_sym => "#{type_params[ind]}" }
  end

  def create_button_name(button_sign, ind)
    text_on_button = emoji ? "#{Emoji.t(emoji[ind])}#{button_sign}" : button_sign
    { text: "#{text_on_button}" }
  end

end
