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
      MSG_TYPES = %i[text audio document video video_note voice photo contact command data webhook].freeze

      attr_reader :command_list, :responder

      def initialize(responder)
        @options = {}
        @responder = responder
        @command_list = Teachbase::Bot::CommandList.new
        set_default_options
      end

      def set_default_options
        @options[:respond] = self
      end

      def init_controller
        case responder.message
        when Telegram::Bot::Types::CallbackQuery
          data
        when Telegram::Bot::Types::Message, OpenStruct
          command? ? command : define_msg_type
        when Teachbase::Bot::Webhook
          webhook
        end
      end

      def webhook
        Teachbase::Bot::WebhookController.new(@options)
      end

      def data
        Teachbase::Bot::CallbackController.new(@options)
      end

      def command
        Teachbase::Bot::CommandController.new(@options)
      end

      def text
        Teachbase::Bot::TextController.new(@options)
      end

      def audio
        Teachbase::Bot::FileController::Audio.new(@options)
      end

      def document
        Teachbase::Bot::FileController::Document.new(@options)
      end

      def video
        Teachbase::Bot::FileController::Video.new(@options)
      end

      def video_note
        Teachbase::Bot::FileController::VideoNote.new(@options)
      end

      def voice
        Teachbase::Bot::FileController::Voice.new(@options)
      end

      def photo
        Teachbase::Bot::FileController::Photo.new(@options)
      end

      def contact
        Teachbase::Bot::ContactController.new(@options)
      end

      def ai
        Teachbase::Bot::AIController.new(@options)
      end

      def reload_commands
        I18n.with_locale responder.settings.localization.to_sym do
          @command_list = Teachbase::Bot::CommandList.new
        end
      end

      def command?
        command_list.command_by?(:value, responder.message)
      end

      private

      def define_msg_type
        msg_type =
        MSG_TYPES.select do |type|
          responder.message.respond_to?(type) && responder.message.public_send(type) && ![*responder.message.public_send(type)].empty?
        end
        msg_type = msg_type.first
        raise "Can't find message type for class: '#{responder.message.class}'. Avaliable: #{MSG_TYPES}" unless msg_type

        public_send(msg_type)
      end
    end
  end
end
