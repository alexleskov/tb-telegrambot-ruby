# frozen_string_literal: true

require './lib/buttons/button'

class Keyboard
  class << self
    def collect(params)
      return unless params[:buttons]

      entity = new(params)
      entity.create
      entity
    end

    def g(params)
      entity = new(params)
      entity.build_buttons
      entity.create
      entity
    end
  end

  attr_reader :buttons,
              :back_button,
              :buttons_signs,
              :buttons_actions,
              :commands,
              :value,
              :emojis,
              :command_prefix

  def initialize(params)
    @buttons = params[:buttons]
    @back_button = params[:back_button]
    @buttons_signs = params[:buttons_signs]
    @buttons_actions = params[:buttons_actions]
    @emojis = params[:emojis]
    @command_prefix = params[:command_prefix]
    @commands = params[:commands]
  end

  def create
    raise "Can't find buttons for keyboard" unless buttons
    raise "Buttons must be an Array. Given: '#{buttons.class}'" unless buttons.is_a?(Array)

    @value = []
    buttons.each do |button|
      value << [button]
    end
    back = init_back_button(back_button) if back_button
    back ? value << [back] : value
  end

  def check_building_params
    raise "Can't find buttons sign" unless buttons_signs
    raise "Expected an Array for buttons signs. You gave #{buttons_signs.class}" unless buttons_signs.is_a?(Array)
  end

  def raw
    raise "Can't find keyboard value" unless value

    clear_trash(value)
    raise "Can't give keyboard. No buttons here" if value.empty?

    value.map! { |button| [button.first.value] }
  end

  def build_buttons
    check_building_params
    @buttons = []

    buttons_signs.each_with_index do |button_sign, ind|
      options = { button_sign: button_sign, command_prefix: command_prefix }
      options[:emoji] = emojis[ind] if emojis
      options.merge!(button_action_type.to_sym => buttons_actions[ind]) if buttons_actions
      options.merge!(commands: commands) if commands
      buttons << button_class.g(options)
    end
    buttons
  end

  protected

  def clear_trash(keyboard)
    keyboard.reject! { |button| button.first.nil? }
  end

  def button_action_type
    button_class::ACTION_TYPE
  end

  def give_indexes(buttons_signs)
    (1..buttons_signs.size).to_a
  end

  def init_back_button(options)
    raise unless options.is_a?(Hash)

    case options[:mode]
    when :custom
      InlineCallbackButton.custom_back(options[:action])
    when :basic
      InlineCallbackButton.back(options[:sent_messages])
    else
      return
    end
  end
end
