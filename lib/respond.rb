# frozen_string_literal: true

require './lib/command_list'
require './controllers/text_controller'
require './controllers/callback_controller'
require './controllers/command_controller'
require './controllers/file_controller/document'
require './controllers/file_controller/photo'
require './controllers/file_controller/video'
require './controllers/file_controller/audio'
require './controllers/file_controller/video_note'
require './controllers/file_controller/voice'
require './controllers/ai_controller/'

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

      def detect_type(mode)
        @mode = mode
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
        action = Teachbase::Bot::TextController.new(@params).match_text_action
        @mode == :ai_on ? ai_controller.match_ai_skill : action
      end

      def audio
        Teachbase::Bot::FileController::Audio.new(@params)
      end

      def document
        Teachbase::Bot::FileController::Document.new(@params)
      end

      def video
        Teachbase::Bot::FileController::Video.new(@params)
      end

      def video_note
        Teachbase::Bot::FileController::VideoNote.new(@params)
      end

      def voice
        Teachbase::Bot::FileController::Voice.new(@params)
      end

      def photo
        Teachbase::Bot::FileController::Photo.new(@params)
      end

      def reload_commands
        @commands = Teachbase::Bot::CommandList.new
      end

      private

      def ai_controller
        Teachbase::Bot::AIController.new(@params)
      end

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
