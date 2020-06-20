# frozen_string_literal: true

module Teachbase
  module Bot
    class AnswerController
      include Formatter

      MSG_DESTS = %i[chat from].freeze

      attr_reader :msg_params

      def initialize(respond, dest)
        @logger = AppConfigurator.new.load_logger
        raise "No such dest '#{dest}' for send answer" unless MSG_DESTS.include?(dest)

        @dest = dest
        @respond = respond
        @settings = respond.msg_responder.settings
        @tg_user = respond.msg_responder.tg_user
        @msg_params = {}
      end

      def create(options)
        raise "Can't find destination for message #{@respond.msg_responder}" unless destination

        @msg_params = options
        @msg_params[:disable_notification] = options[:disable_notification]
        @msg_params[:disable_web_page_preview] = options[:disable_web_page_preview]
        @msg_params[:text] = options[:text].squeeze(" ") if options[:text]
        @msg_params[:tg_user] = @tg_user
        @msg_params[:bot] = @respond.msg_responder.bot
        @msg_params[:chat] = destination # TODO: Add option options[:to_chat_id]
      end

      protected

      def destination
        @respond.msg_responder.message.public_send(@dest) if @respond.msg_responder.message.respond_to? @dest
      end
    end
  end
end
