# frozen_string_literal: true

module Teachbase
  module Bot
    class AnswerController
      include Formatter

      MSG_DESTS = %i[chat from].freeze

      attr_reader :msg_params, :command_list

      def initialize(respond, dest)
        raise "No such dest '#{dest}' for send answer" unless MSG_DESTS.include?(dest)

        @dest = dest
        @respond = respond
        @settings = respond.msg_responder.settings
        @command_list = respond.commands
        @msg_params = { bot: respond.msg_responder.bot, tg_user: respond.msg_responder.tg_user }
      end

      def create(options)
        raise "Can't find destination for message #{@respond.msg_responder}" unless destination
        raise unless options.is_a?(Hash)

        @msg_params.merge!(options)
        @msg_params[:text] = options[:text].squeeze(" ") if options[:text]
        @msg_params[:chat] = destination
      end

      protected

      def destination
        @respond.msg_responder.message.public_send(@dest) if @respond.msg_responder.message.respond_to? @dest
      end
    end
  end
end
