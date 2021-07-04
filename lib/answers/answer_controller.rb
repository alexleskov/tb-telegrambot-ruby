# frozen_string_literal: true

module Teachbase
  module Bot
    class AnswerController
      include Formatter

      MSG_DESTS = %i[chat from tg_account].freeze

      attr_reader :command_list,
                  :bot,
                  :tg_user,
                  :message,
                  :user_settings,
                  :text,
                  :chat_id,
                  :bot_messages,
                  :parse_mode,
                  :disable_notification,
                  :disable_web_page_preview,
                  :reply_to_message_id,
                  :reply_to_tg_id,
                  :message_type,
                  :mode

      def initialize(config_params, dest)
        raise "No such dest '#{dest}' for send answer" unless MSG_DESTS.include?(dest)

        @mode = nil
        @dest = dest
        @bot = config_params[:bot]
        @tg_user = config_params[:tg_user]
        @bot_messages = tg_user.bot_messages
        @command_list = config_params[:command_list]
        @message = config_params[:message]
        @user_settings = config_params[:user_settings]
      end

      def create(options)
        raise unless options.is_a?(Hash)

        @reply_to_message_id = options[:reply_to_message_id]
        @reply_to_tg_id = options[:reply_to_tg_id]
        @chat_id = find_chat_id
        @text = options[:text].to_s.squeeze(" ") if options[:text]
        @parse_mode = options[:parse_mode] || $app_config.load_parse_mode
        @disable_notification = !!options[:disable_notification]
        @disable_web_page_preview = !!options[:disable_web_page_preview]
      end

      def push
        MessageSender.new(self).send_now
      end

      protected

      def find_chat_id
        finded_id =
          if reply_to_tg_id
            reply_to_tg_id
          elsif reply_to_message_id
            reply_to_message_id
          else
            destination.id
          end
        raise "Can't find chat_id" unless finded_id

        finded_id.to_i
      end

      def destination
        return unless message

        @dest = message.respond_to?(@dest) ? @dest : MSG_DESTS.select { |msg_dest| message.respond_to?(msg_dest) }.first
        message.public_send(@dest)
      end
    end
  end
end
