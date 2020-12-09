# frozen_string_literal: true

require './lib/command_list'
require './controllers/text_controller'
require './controllers/callback_controller'
require './controllers/command_controller'
require './controllers/webhook_controller'
require './controllers/ai_controller/'
require './controllers/contact_controller/'
require './controllers/file_controller/document'
require './controllers/file_controller/photo'
require './controllers/file_controller/video'
require './controllers/file_controller/audio'
require './controllers/file_controller/video_note'
require './controllers/file_controller/voice'

module Teachbase
  module Bot
    class Respond
      MSG_TYPES = %i[text audio document video video_note voice photo request_body contact].freeze

      attr_reader :command_list, :msg_responder

      def initialize(responder)
        @msg_responder = responder
        @message = msg_responder.message
        @command_list = Teachbase::Bot::CommandList.new
      end

      def go(options = {})
        @options = options
        options[:ai_mode] ||= $app_config.ai_mode.to_sym
        @params = { respond: self }

        case @message
        when Telegram::Bot::Types::CallbackQuery
          cb_controller = Teachbase::Bot::CallbackController.new(@params)
          cb_controller.match_data
          return cb_controller if cb_controller.c_data

          cb_controller.message.data
        when Telegram::Bot::Types::Message
          if command?
            Teachbase::Bot::CommandController.new(@params).push_command
          else
            define_msg_type
          end
        else @message.is_a?(Teachbase::Bot::Webhook)
             define_msg_type
        end
      end

      def request_body
        Teachbase::Bot::WebhookController.new(@params).match_webhook_event
      end

      def text
        text_controller = Teachbase::Bot::TextController.new(@params)
        text_controller.match_text_action

        @options[:ai_mode] == :on && !text_controller.c_data ? ai_controller.match_ai_skill : text_controller
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

      def contact
        Teachbase::Bot::ContactController.new(@params)
      end

      def reload_commands
        @command_list = Teachbase::Bot::CommandList.new
      end

      def command?
        command_list.command_by?(:value, @message)
      end

      private

      def ai_controller
        Teachbase::Bot::AIController.new(@params)
      end

      def define_msg_type
        msg_type = MSG_TYPES.each do |type|
          if @message.respond_to?(type) && @message.public_send(type) && ![*@message.public_send(type)].empty?
            break type
          end
        end
        raise "Don't know such message type: '#{@message.class}'. Avaliable: #{MSG_TYPES}" unless msg_type

        public_send(msg_type)
      end
    end
  end
end
