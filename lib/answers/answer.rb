# frozen_string_literal: true

require './models/auth_session'

module Teachbase
  module Bot
    class Answer
      include Formatter

      MSG_DESTS = %i[chat from].freeze

      attr_reader :msg_params

      def initialize(appshell, param)
        @logger = AppConfigurator.new.load_logger
        raise "No such param '#{param}' for send answer" unless MSG_DESTS.include?(param)

        @param = param
        @appshell = appshell
        @respond = appshell.controller.respond
        @tg_user = @respond.incoming_data.tg_user
        @settings = @respond.incoming_data.settings
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

      def user_fullname(option)
        user_name = @appshell.user_fullname
        case option
        when :string
          user_name.join(" ")
        when :array
          user_name
        else
          raise "Don't know such option: #{option}. Use: ':string', ':array'"
        end
      end

      protected

      def destination
        @respond.incoming_data.message.public_send(@param) if @respond.incoming_data.message.respond_to? @param
      end
    end
  end
end
