# frozen_string_literal: true

class Button
  include Formatter
  
  class << self
    def g(type, options)
      entity = new(type, options)
      entity.create
      entity
    end
  end

  attr_reader :type,
              :command_prefix,
              :button_sign,
              :emoji,
              :position,
              :value

  def initialize(type, options)
    @type = type
    @options = options
    @button_sign = options[:button_sign]
    @emoji = options[:emoji]
    @command_prefix = options[:command_prefix] || ""
    @position = options[:position]
  end

  def create
    raise "Can't find button sign" unless button_sign

    @value = create_button_name.merge(create_action)
  end

  protected

  def find_param
    @options[type.to_sym] || button_sign
  end

  def create_action
    { type.to_sym => find_param.to_s }
  end

  def create_button_name
    text_on_button = emoji ? "#{Emoji.t(emoji)}#{button_sign}" : button_sign
    { text: text_on_button.to_s }
  end
end
