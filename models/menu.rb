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
                        chat: destination,
                        text: text, type => { buttons: buttons, slices: slices_count } }
        MessageSender.new(menu_params).send
      end

      def starting(text = "#{I18n.t('start_menu_message')}")
        buttons = [commands.show(:signin), commands.show(:settings)]
        create(buttons, :menu, text, 1)
      end

      def after_auth
        buttons = [commands.show(:course_list_l1), commands.show(:show_profile_state), commands.show(:settings), commands.show(:update_profile_data)]
        create(buttons, :menu, I18n.t('start_menu_message'), 3)
      end

      def course_sessions_choice
        buttons = [[text: I18n.t('active_courses').capitalize!, callback_data: "active_courses"], [text: I18n.t('archived_courses').capitalize!, callback_data: "archived_courses"]]
        create(buttons, :menu_inline, "#{Emoji.find_by_alias('books').raw}<b>#{I18n.t('show_course_list')}</b>", 2)
      end

      def testing
        buttons = [[text: "TOUCH", callback_data: "touch"], [text: "teachbase.ru", url: "http://teachbase.ru"]]
        create(buttons, :menu_inline, "Test inline menu", 2)
      end

      def hide
        MessageSender.new(bot: message_responder.bot, chat: destination,
                          text: "-----------------------------", hide_kb: true).send
      end

    end
  end
end
