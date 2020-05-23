# frozen_string_literal: true

module Teachbase
  module Bot
    class Answer
      include Formatter

      MSG_DESTS = %i[chat from].freeze

      attr_reader :msg_params

      def initialize(respond, dest)
        @logger = AppConfigurator.new.load_logger
        raise "No such dest '#{dest}' for send answer" unless MSG_DESTS.include?(dest)

        @dest = dest
        @respond = respond
        @settings = respond.incoming_data.settings
        @tg_user = respond.incoming_data.tg_user
        @msg_params = {}
      end

      def create(options)
        raise "Can't find destination for message #{@respond.incoming_data}" unless destination

        @msg_params = options
        @msg_params[:disable_notification] = options[:disable_notification]
        @msg_params[:text] = options[:text].squeeze(" ") if options[:text]
        @msg_params[:tg_user] = @tg_user
        @msg_params[:bot] = @respond.incoming_data.bot
        @msg_params[:chat] = destination # TODO: Add option options[:to_chat_id]
      end

      protected

      def destination
        @respond.incoming_data.message.public_send(@dest) if @respond.incoming_data.message.respond_to? @dest
      end
    end
  end
end
