require './lib/message_sender'
require './controllers/controller'

module Teachbase
  module Bot
    class Menu

      attr_reader :message_responder, :commands

      def initialize(message_responder, param)
        raise "No such param '#{param}' for send menu" unless [:chat,:from].include?(param)

        @param = param
        @message_responder = message_responder
        @commands = message_responder.commands
      end

      def create(buttons, type, text, slices_count = nil)
        raise "'buttons' must be Array" unless buttons.is_a?(Array)
        raise "No such menu type: #{type}" unless %i[menu menu_inline].include?(type)
        raise "Can't find menu destination for message #{message_responder}" if destination.nil?

        menu_params = { bot: message_responder.bot,
                        chat: destination,
                        text: text, type => { buttons: buttons, slices: slices_count } }
        MessageSender.new(menu_params).send
      end

      def starting(text = "#{I18n.t('start_menu_message')}")
        buttons = [commands.show(:signin), commands.show(:settings)]
        create(buttons, :menu, text, 2)
      end

      def after_auth
        buttons = [commands.show(:course_list_l1),
                   commands.show(:show_profile_state),
                   commands.show(:settings),
                   commands.show(:sign_out)]
        create(buttons, :menu, I18n.t('start_menu_message'), 2)
      end

      def course_sessions_choice
        buttons = [[text: I18n.t('archived_courses').capitalize!, callback_data: "archived_courses"],
                   [text: I18n.t('active_courses').capitalize!, callback_data: "active_courses"],
                   [text: "#{Emoji.find_by_alias('arrows_counterclockwise').raw} #{I18n.t('update_course_sessions')}", callback_data: "update_course_sessions"]]
        create(buttons, :menu_inline, "#{Emoji.find_by_alias('books').raw}<b>#{I18n.t('show_course_list')}</b>", 2)
      end

      def hide
        raise "Can't find menu destination for message #{message_responder}" if destination.nil?
        MessageSender.new(bot: message_responder.bot, chat: destination,
                          text: "-----------------------------", hide_kb: true).send
      end

    private

      def destination
        message_responder.message.public_send(@param) if message_responder.message.respond_to? @param
      end
    end
  end
end
