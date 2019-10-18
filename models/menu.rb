require './lib/message_sender'
require './controllers/controller'

module Teachbase
  module Bot
    class Menu

      attr_reader :user, :message_responder, :destination, :commands

      def initialize(message_responder, param)
        raise "No such param '#{param}' for send menu" unless [:chat,:from].include?(param)
        msg = message_responder.message
        @destination = msg.public_send(param) if msg.respond_to? param
        raise "Can't find menu destination for message #{message_responder}" if destination.nil?
        @user = message_responder.user
        @message_responder = message_responder
        @commands = message_responder.commands
        @logger = AppConfigurator.new.get_logger
        @logger.debug "commands: '#{message_responder.commands.all}"
      end

      def create(buttons, type, text, slices_count = nil)
        raise "'buttons' must be Array" unless buttons.is_a?(Array)
        raise "No such menu type: #{type}" unless %i[menu menu_inline].include?(type)

        menu_params = { bot: message_responder.bot,
                        chat: message_responder.message.chat,
                        text: text, type => { buttons: buttons, slices: slices_count } }
        MessageSender.new(menu_params).send
      end

      def starting
        buttons = [commands.get_value(:signin), commands.get_value(:settings)]
        @logger.debug "buttons: '#{[commands.get_value(:signin), commands.get_value(:settings)]}"
        create(buttons, :menu, I18n.t('start_menu_message'))
      end

      def testing
        buttons = [[text: "TOUCH", callback_data: "touch"], [text: "teachbase.ru", url: "http://teachbase.ru"]]
        create(buttons, :menu_inline, "Test inline menu", 2)
      end

      def hide
        MessageSender.new(bot: message_responder.bot, chat: message_responder.message.chat, text: I18n.t('farewell_message'), hide_kb: true).send
      end

    end
  end
end
