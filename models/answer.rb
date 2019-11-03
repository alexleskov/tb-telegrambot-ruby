require './lib/message_sender'

module Teachbase
  module Bot
    class Answer
      attr_reader :user, :message_responder, :destination

      def initialize(message_responder, user, param)
        raise "No such param '#{param}' for send answer" unless [:chat,:from].include?(param)
        
        @param = param
        @user = user
        @message_responder = message_responder
      end

      def send(text)
        raise "Can't find answer destination for message #{message_responder}" if destination.nil?
        MessageSender.new(bot: message_responder.bot, chat: destination, text: text).send
      end

      def send_greeting_message
        first_name = message_responder.tg_user.first_name
        last_name = message_responder.tg_user.last_name
        send("#{I18n.t('greeting_message')} <b>#{first_name} #{last_name}!</b>")
      end

      def send_farewell_message
        first_name = message_responder.tg_user.first_name
        last_name = message_responder.tg_user.last_name
        send("#{I18n.t('farewell_message')} #{first_name} #{last_name}!")
      end

    private
      
      def destination
        message_responder.message.public_send(@param) if message_responder.message.respond_to? @param
      end
    end
  end
end
