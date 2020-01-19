require './lib/command_list'
require './controllers/controller'
require './controllers/action_controller'
require './controllers/callback_controller'
require './controllers/command_controller'
require './lib/scenarios.rb'

module Teachbase
  module Bot
    class Respond
      attr_reader :commands, :incoming_data

      def initialize(message_responder)
        @incoming_data = message_responder
        @commands = Teachbase::Bot::CommandList.new
      end

      def detect_type
        params = {respond: self}
        case incoming_data.message
        when Telegram::Bot::Types::CallbackQuery
          Teachbase::Bot::CallbackController.new(params).match_data
        when Telegram::Bot::Types::Message
          if command?
            Teachbase::Bot::CommandController.new(params).push_command
          else
            Teachbase::Bot::ActionController.new(params).match_text_action
          end
        else
          raise "Don't know such Telegram::Bot::Types: #{incoming_data.message.class}"
        end
      end

      private

      def command?
        commands.command_by?(:value, incoming_data.message.text)
      end
    end
  end
end
