require './models/user'
require './lib/command_list'
require './controllers/controller'
require './controllers/action_controller'
require './controllers/callback_controller'


class MessageResponder
  attr_reader :message, :bot, :user, :tg_info, :commands

  def initialize(options)
    @tg_info = {}
    @bot = options[:bot]
    @message = options[:message]
    @user = Teachbase::Bot::User.find_or_create_by!(uid: message.from.id)
    @tg_info[:first_name] = message.from.first_name
    @tg_info[:last_name] = message.from.last_name
    @commands = Teachbase::Bot::CommandList.new
  end

  def respond
    if message.is_a?(Telegram::Bot::Types::CallbackQuery)
      Teachbase::Bot::CallbackController.new(self).match_data
    elsif commands.command_by_value?(message.text)
      command = commands.find_by_value(message.text)
      command = command.key
      action = Teachbase::Bot::ActionController.new(self)
      raise "Can't respond on such command: #{command}. See 'Teachbase::Bot::Controller" if !action.respond_to? command
      action.public_send(command)
    else
      Teachbase::Bot::ActionController.new(self).match_data
    end
  end
end
