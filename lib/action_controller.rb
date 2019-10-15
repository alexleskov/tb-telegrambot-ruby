require './models/user'
require './lib/message_sender'
require './lib/message_responder'

module Teachbase
  module Bot
    class ActionController
      attr_reader :user, :message_responder

      def initialize(message_responder)
        @user = message_responder.user
        @message_responder = message_responder
        @logger = AppConfigurator.new.get_logger
        #@logger.debug "mes_res: '#{message_responder}"
      end

      def answer(text)
        MessageSender.new(bot: message_responder.bot, chat: message_responder.message.chat, text: text).send
      end

      def take_data
        message_responder.bot.listen do |message|
          @logger.debug "taking data: @#{message.from.username}: #{message.text}"
          break message.text
        end
      end

      def match_data
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
      end

      def hello
        answer_with_greeting_message
      end

      def signin
        answer I18n.t('add_user_email')
        user.email = take_data
        answer I18n.t('add_user_password')
        user.password = take_data
        user.save
        @logger.debug "user: #{user.email}, #{user.password}, #{user.first_name}"
      end

    private

      def answer_with_greeting_message
        answer I18n.t('greeting_message') + " #{user.first_name} #{user.last_name}!"
      end

      def answer_with_farewell_message
        answer I18n.t('farewell_message') + " #{user.first_name} #{user.last_name}!"
      end

      def hide_kb
        MessageSender.new(bot: message_responder.bot, chat: message_responder.message.chat, text: I18n.t('thanks') + "!", hide_kb: true).send
      end

      def strating_menu
        buttons = [message_responder.tb_bot_client.commands[:signin], message_responder.tb_bot_client.commands[:settings]]
        MessageSender.new(bot: message_responder.bot,
                          chat: message_responder.message.chat,
                          text: I18n.t('start_menu_message'),
                          menu: { answers: buttons, slices: 1}).send
      end

      def on command, &block
        command =~ message_responder.message.text
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
      end

    end
  end
end