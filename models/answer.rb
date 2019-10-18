require './lib/message_sender'
require './controllers/controller'

module Teachbase
  module Bot
    class Answer

      attr_reader :user, :message_responder, :tg_info, :destination, :commands

      def initialize(message_responder, param)
        raise "No such param '#{param}' for send answer" unless [:chat,:from].include?(param)
        msg = message_responder.message
        @destination = msg.public_send(param) if msg.respond_to? param
        raise "Can't find answer destination for message #{message_responder}" if destination.nil?
        @user = message_responder.user
        @message_responder = message_responder
        @commands = message_responder.commands
        @tg_info = message_responder.tg_info
        @logger = AppConfigurator.new.get_logger
        # @logger.debug "mes_res: '#{message_responder}"
      end

      def send(text)
        MessageSender.new(bot: message_responder.bot, chat: destination, text: text).send
      end

      def send_greeting_message
        first_name = user.first_name.nil? ? tg_info[:first_name] : user.first_name
        last_name = user.first_name.nil? ? tg_info[:last_name] : user.last_name
        send("#{I18n.t('greeting_message')} #{first_name} #{last_name}!")
      end

      def send_farewell_message
        first_name = user.first_name.nil? ? tg_info[:first_name] : user.first_name
        last_name = user.first_name.nil? ? tg_info[:last_name] : user.last_name
        send("#{I18n.t('farewell_message')} #{first_name} #{last_name}!")
      end
    end
  end
end
