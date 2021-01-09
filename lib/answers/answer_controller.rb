# frozen_string_literal: true

module Teachbase
  module Bot
    class AnswerController
      include Formatter

      MSG_DESTS = %i[chat from tg_account].freeze

      attr_reader :msg_params, :command_list, :bot, :tg_user, :message, :user_settings

      def initialize(config_params, dest)
        raise "No such dest '#{dest}' for send answer" unless MSG_DESTS.include?(dest)

        @dest = dest
        @bot = config_params[:bot]
        @tg_user = config_params[:tg_user]
        @command_list = config_params[:command_list]
        @message = config_params[:message]
        @user_settings = config_params[:user_settings]
        @msg_params = { bot: bot, tg_user: tg_user }
      end

      def create(options)
        raise unless options.is_a?(Hash)

        @msg_params.merge!(options)
        @msg_params[:text] = options[:text].to_s.squeeze(" ") if options[:text]
        @msg_params[:chat_id] = find_chat_id
        raise "Can't find destination" unless @msg_params[:chat_id]
      end

      protected

      def destination
        return unless message

        @dest =
        if message.respond_to?(@dest)
          @dest
        else
          MSG_DESTS.select { |msg_dest| message.respond_to?(msg_dest) }.first
        end
        message.public_send(@dest)
      end

      def find_chat_id
        msg_params[:reply_to_tg_id] ? msg_params[:reply_to_tg_id].to_i : destination.id
      end
    end
  end
end
