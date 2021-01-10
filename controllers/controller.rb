# frozen_string_literal: true

module Teachbase
  module Bot
    class Controller
      include Formatter
      include Decorators

      TAKING_DATA_CONTEXT_STATE = "taking_data"

      attr_reader :respond,
                  :message_params,
                  :filer,
                  :interface,
                  :c_data,
                  :action_result,
                  :type

      def initialize(params, dest)
        @respond = params[:respond]
        @dest = dest
        raise "Respond not found" unless respond

        @message_params = { message_controller_class: self.class.to_s }
        @interface = Teachbase::Bot::Interfaces
        interface.configure(build_interface_config_params, dest)
        @filer = Teachbase::Bot::Filer.new($app_config.tg_bot_client)
      rescue RuntimeError => e
        $logger.debug "Initialization Controller error: #{e}"
      end

      def context
        respond.responder
      end

      def take_data
        context.tg_user.update!(context_state: TAKING_DATA_CONTEXT_STATE)
        loop do
          next if context.tg_user.on_taking_data?

          message = Teachbase::Bot::CacheMessage.raise_last_message_by(context.tg_user)
          taked_context = MessageResponder.new(bot: $app_config.tg_bot_client, tg_id: context.tg_user.id, message: message)
          taked_strategy = taked_context.handle

          break taked_strategy.controller
        end
      end

      def save_message(mode)
        return unless context.tg_user && context.message

        @message_params[:message_id] = message_id
        @message_params[:message_type] ||= type
        @message_params[:data] ||= source
        case mode
        when :perm
          context.tg_user.tg_account_messages.create!(message_params)
        when :cache
          context.tg_user.cache_messages.create!(message_params)
        else
          raise "No such mode: '#{mode}' for saving message"
        end
      end

      def reload_commands_list
        respond.reload_commands
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
        { tg_user: context.tg_user,
          bot: $app_config.tg_bot_client,
          message: context.message,
          user_settings: context.settings,
          command_list: respond.command_list }
      end

      def find_msg_value(msg_type)
        context.message.public_send(msg_type) if context.message.respond_to?(msg_type)
      end

      def message_id
        context.message.respond_to?(:message_id) ? context.message.message_id : context.message.message.message_id
      end
    end
  end
end
