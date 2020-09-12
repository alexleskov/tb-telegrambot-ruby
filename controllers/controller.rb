# frozen_string_literal: true

require './lib/app_shell'
require './lib/filer'
require './lib/breadcrumb'
require './lib/interfaces/interfaces'
require './routers/routers/'

module Teachbase
  module Bot
    class Controller
      include Formatter
      include Decorators

      attr_reader :respond,
                  :appshell,
                  :tg_user,
                  :message,
                  :message_params,
                  :filer,
                  :interface,
                  :router

      def initialize(params, dest)
        @respond = params[:respond]
        raise "Respond not found" unless respond

        @tg_user = respond.msg_responder.tg_user
        @message = respond.msg_responder.message
        @message_params = {}
        @interface = Teachbase::Bot::Interfaces.new(respond, dest)
        @filer = Teachbase::Bot::Filer.new(respond)
        @router = Teachbase::Bot::Routers.new
        @appshell = Teachbase::Bot::AppShell.new(self)
      rescue RuntimeError => e
        $logger.debug "Initialization Controller error: #{e}"
      end

      def take_data
        respond.msg_responder.bot.listen do |taking_message|
          # $logger.debug "taking data: @#{taking_message.from.username}: #{taking_message}"
          options = { bot: respond.msg_responder.bot, message: taking_message }
          break MessageResponder.new(options).detect_type if taking_message
        end
      end

      def save_message(mode)
        return unless tg_user || message
        return if message_params.empty?

        message_params.merge!(message_id: message_id)
        case mode
        when :perm
          tg_user.tg_account_messages.create!(message_params)
        when :cache
          tg_user.cache_messages.create!(message_params)
        else
          raise "No such mode: '#{mode}' for saving message"
        end
      end

      protected

      def find_msg_value(msg_type)
        message.public_send(msg_type) if message.respond_to?(msg_type)
      end

      def on(command, msg_type, &block)
        command =~ @message_value = find_msg_value(msg_type)

        p "command: #{command}"
        p "@message_value": {@message_value}
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

      def message_id
        message.respond_to?(:message_id) ? message.message_id : message.message.message_id
      end
    end
  end
end
