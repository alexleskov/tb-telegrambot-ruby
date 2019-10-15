require './models/user'
require './lib/action_controller'
require './lib/message_sender'

class MessageResponder
  attr_reader :message, :bot, :user, :tb_bot_client

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id, first_name: message.from.first_name, last_name: message.from.last_name)
    @tb_bot_client = options[:tb_bot_client]
  end

  def respond
    if tb_bot_client.commands.values.include?(message.text)
      command = tb_bot_client.commands.key(message.text)
      action = Teachbase::Bot::ActionController.new(self)
      action.public_send(command) if action.respond_to? command
    else
      Teachbase::Bot::ActionController.new(self).match_data
    end 
  end
end
