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
              :value,
              :action_type

  def initialize(type, options)
    @type = type
    @options = options
    @button_sign = options[:button_sign]
    @emoji = options[:emoji]
    @command_prefix = options[:command_prefix] || ""
    @position = options[:position]
    @action_type = options[:action_type]
  end

  def create
    raise "Can't find button sign" unless button_sign

    @value = create_button_name
  end

  protected

  def find_param
    @options[type.to_sym] || button_sign
  end

  def create_button_name
    { text: text_on_button.to_s }
  end

  def text_on_button
    if emoji
      emoji == :arrow_right ? "#{button_sign} #{Emoji.t(emoji)}" : "#{Emoji.t(emoji)} #{button_sign}"
    else
      button_sign
    end
  end
end
