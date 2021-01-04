# frozen_string_literal: true

module Teachbase
  module Bot
    class Controller
      include Formatter
      include Decorators

      TAKING_DATA_CONTEXT_STATE = "taking_data"

      attr_reader :respond,
                  :tg_user,
                  :user_settings,
                  :bot,
                  :message,
                  :command_list,
                  :message_params,
                  :filer,
                  :interface,
                  :c_data,
                  :ai_mode,
                  :action_result

      def initialize(params, dest)
        @respond = params[:respond]
        @ai_mode = params[:ai_mode]
        @dest = dest
        raise "Respond not found" unless respond

        fetch_respond_data
        @message_params = {}
        @interface = Teachbase::Bot::Interfaces
        interface.configure(build_interface_config_params, dest)
        @filer = Teachbase::Bot::Filer.new(bot)
      rescue RuntimeError => e
        # $logger.debug "Initialization Controller error: #{e}"
      end

      def take_data
        tg_user.update!(context_state: TAKING_DATA_CONTEXT_STATE)
        loop do
          tg_user.reload
          if tg_user.context_state != TAKING_DATA_CONTEXT_STATE
            break Teachbase::Bot::Cache.extract_by(tg_user, "MessageResponder").first.message.handle.controller
          end
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

      def reload_commands_list
        respond.reload_commands
        fetch_respond_data
        interface.configure(build_interface_config_params, @dest)
      end

      def on(command, msg_type)
        command =~ find_msg_value(msg_type)
        return unless $LAST_MATCH_INFO

        @c_data ||= $LAST_MATCH_INFO
        @action_result = yield
      end

      protected

      def build_interface_config_params
        { tg_user: tg_user, bot: bot, message: message, user_settings: user_settings, command_list: command_list }
      end

      def fetch_respond_data
        @tg_user = respond.msg_responder.tg_user
        @bot = respond.msg_responder.bot
        @message = respond.msg_responder.message
        @user_settings = respond.msg_responder.settings
        @command_list = respond.command_list
      end

      def find_msg_value(msg_type)
        message.public_send(msg_type) if message.respond_to?(msg_type)
      end

      def message_id
        message.respond_to?(:message_id) ? message.message_id : message.message.message_id
      end
    end
  end
end
