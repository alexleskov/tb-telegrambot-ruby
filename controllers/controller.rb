# frozen_string_literal: true

require './lib/app_shell'
require './lib/answers/answers'
require './interfaces/breadcrumb'

module Teachbase
  module Bot
    class Controller
      include Formatter
      include Viewers

      MSG_TYPES = %i[text data].freeze

      attr_reader :respond, :answer, :appshell, :tg_user

      def initialize(params, dest)
        @respond = params[:respond]
        raise "Respond not found" unless respond

        @tg_user = respond.incoming_data.tg_user
        @message = respond.incoming_data.message
        @logger = AppConfigurator.new.load_logger
        @appshell = Teachbase::Bot::AppShell.new(self)
        @interface = Teachbase::Bot::ObjInterface.new(self)
        @answer = Teachbase::Bot::Answers.new(respond, dest)
      rescue RuntimeError => e
        @logger.debug "Initialization Controller error: #{e}"
      end

      protected

      def find_msg_value(msg_type)
        case msg_type
        when :text
          @message.text
        when :data
          @message.data
        else
          raise "Can't find message for #{@message}, type: #{msg_type}, available: #{MSG_TYPES}"
        end
      end

      def on(command, msg_type, &block)
        raise "No such message type '#{msg_type}'. Must be a one of #{MSG_TYPES}" unless MSG_TYPES.include?(msg_type)

        command =~ @message_value = find_msg_value(msg_type)
        return unless $LAST_MATCH_INFO

        case block.arity
        when 0
          yield
        when 1
          yield $1
        when 2
          yield $1, $2
        end
      end

      def save_message(result_data = {})
        return unless @tg_user || @message
        return if result_data.empty?

        @tg_user.tg_account_messages.create!(result_data)
      end
    end
  end
end
