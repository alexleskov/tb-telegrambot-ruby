require './models/user'
require './lib/message_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  attr_reader :commands

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.find_or_create_by(uid: message.from.id, first_name: message.from.first_name, last_name: message.from.last_name)
    @commands = [Emoji.find_by_alias("rocket").raw + I18n.t('signin'), Emoji.find_by_alias("wrench").raw + I18n.t('settings')]
  end

  def respond
    on /^\/start/ do
      answer_with_greeting_message
      strating_menu
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end

    on /^\/hide_menu/ do
      hide_kb
    end

    on commands[0] do
      answer_with_farewell_message
    end
  end

  private

  def on command, &block
    if command.is_a?(Regexp)
      command =~ message.text
      if $~
        case block.arity
        when 0
          yield
        when 1
          yield $1
        when 2
          yield $1, $2
        end
      end
    elsif command.is_a?(String) && commands.include?(command)
      case message.text
      when command
        yield
      end
    end
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message') + " #{user.first_name} #{user.last_name}!"
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message') + " #{user.first_name} #{user.last_name}!"
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def hide_kb
    MessageSender.new(bot: bot, chat: message.chat, text: I18n.t('thanks') + "!", hide_kb: true).send
  end

  def strating_menu
    buttons = [commands[0], commands[1]]
    MessageSender.new(bot: bot,
                      chat: message.chat,
                      text: I18n.t('start_menu_message'),
                      menu: { answers: buttons, slices: 1}).send
  end

end
