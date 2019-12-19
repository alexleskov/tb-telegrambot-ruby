require './lib/command_list'
require './controllers/controller'
require './controllers/action_controller'
require './controllers/callback_controller'

module Teachbase
  module Bot
    class Respond
      attr_reader :commands, :incoming_data

      def initialize(message_responder)
        @incoming_data = message_responder
        @commands = Teachbase::Bot::CommandList.new
      end

      def detect_respond_type
        if incoming_data.message.is_a?(Telegram::Bot::Types::CallbackQuery)
          Teachbase::Bot::CallbackController.new(self).match_data
        elsif command?
          command = find_command
          action = Teachbase::Bot::ActionController.new(self)
          raise "Can't respond on such command: #{command}." if !action.respond_to? command

          action.public_send(command)
        else
          Teachbase::Bot::ActionController.new(self).match_data
        end
      end

      private

      def command?
        commands.command_by?(:value, incoming_data.message.text)
      end

      def find_command
        commands.find_by(:value, incoming_data.message.text).key
      end
    end
  end
end
