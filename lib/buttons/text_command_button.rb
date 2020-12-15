# frozen_string_literal: true

require './lib/buttons/button'

class TextCommandButton < Button
  ACTION_TYPE = :text_command

  class << self
    def g(options)
      super(:text_command, options)
    end

    def take_contact(commands)
      g(request_contact: true, button_sign: :send_contact, commands: commands)
    end
  end

  attr_reader :commands, :request_contact

  def initialize(type, options)
    @commands = options[:commands]
    @request_contact = options[:request_contact]
    super(type, options)
  end

  def create
    super
    @value[:request_contact] = request_contact if request_contact
  end

  protected

  def text_on_button
    commands.show(button_sign).to_s
  end
end
