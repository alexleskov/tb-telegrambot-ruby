# frozen_string_literal: true

module Teachbase
  module Bot
    class AnswerController
      include Formatter

      MSG_DESTS = %i[chat from].freeze

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
        raise "Can't find destination for message '#{message}'" unless destination
        raise unless options.is_a?(Hash)

        @msg_params.merge!(options)
        @msg_params[:text] = options[:text].to_s.squeeze(" ") if options[:text]
        @msg_params[:chat] = destination
      end

      protected

      def destination
        message.public_send(@dest) if message.respond_to? @dest
      end
    end
  end
end
