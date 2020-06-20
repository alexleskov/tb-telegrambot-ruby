# frozen_string_literal: true

require './lib/command_list'
require './controllers/text_controller'
require './controllers/callback_controller'
require './controllers/command_controller'
require './controllers/file_controller/document'
require './controllers/file_controller/photo'

module Teachbase
  module Bot
    class Respond
      MSG_TYPES = %i[text audio document video video_note voice photo].freeze

      attr_reader :commands, :msg_responder

      def initialize(message_responder)
        @msg_responder = message_responder
        @message = msg_responder.message 
        @commands = Teachbase::Bot::CommandList.new
      end

      def detect_type
        @params = { respond: self }

        case @message
        when Telegram::Bot::Types::CallbackQuery
          Teachbase::Bot::CallbackController.new(@params).match_data
        when Telegram::Bot::Types::Message
          if command?
            Teachbase::Bot::CommandController.new(@params).push_command
          else
            define_msg_type
          end
        end
      end

      def text
        Teachbase::Bot::TextController.new(@params).match_text_action
      end

      def document
        Teachbase::Bot::FileController::Document.new(@params)
      end

      def photo
        Teachbase::Bot::FileController::Photo.new(@params)
      end

      def reload_commands
        @commands = Teachbase::Bot::CommandList.new
      end

      private

      def command?
        commands.command_by?(:value, @message)
      end

      def define_msg_type
        msg_type = MSG_TYPES.each do |type|
                    break type if @message.public_send(type)
                  end
        raise "Don't know such Telegram::Bot::Types::Message: '#{@message.class}'. Only: #{MSG_TYPES}" unless msg_type

        public_send(msg_type)
      end
    end
  end
end
