# frozen_string_literal: true

module Teachbase
  module Bot
    class Controller
      include Formatter
      include Decorators

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
        $logger.debug "Initialization Controller error: #{e}"
      end

=begin
      def take_data
        loop do
          p @tg_user.id
          p "HERE"
        end
      end
=end

      def take_data
        msg_controller = nil
        msg = nil
        taked_message = nil
        bot.listen do |rqst|
          thread = Thread.new(rqst) do |taking_message|
            msg = taking_message
            if msg.from.id == @tg_user.id
              p "SAME USER"
              strategy = MessageResponder.new(bot: bot, message: msg).handle
              taked_message = strategy.controller
            else
              p "NOT SAME USER"
              MessageResponder.new(bot: bot, message: msg).handle.do_action
            end
            p "msg.from.id: #{msg.from.id}, @tg_user.id: #{@tg_user.id}"
          end
          thread.join
          break taked_message if msg.from.id == @tg_user.id
        end
      end

=begin
 
      def take_data
        msg_controller = nil
        msg = nil
        taked_message = nil
        bot.listen do |rqst|
          p "HERE TAKE DATA"
          thread = Thread.new(rqst) do |taking_message|
            msg = taking_message
            if msg.from.id == @tg_user.id
              p "SAME USER"
              taked_message = MessageResponder.new(bot: bot, message: msg).build_respond.go(ai_mode: :off)
            else
              p "NOT SAME USER"
              MessageResponder.new(bot: bot, message: msg).build_respond.go
            end
            p "msg.from.id: #{msg.from.id}, @tg_user.id: #{@tg_user.id}"
          end
          thread.join
          break taked_message if msg.from.id == @tg_user.id
        end
      end 

  
=end

=begin
      def take_data
        p "HEREEEEE"
        msg_controller = nil
        msg = nil
        respond_controller = nil
        bot.listen do |rqst|
          p "HERE TAKE DATA"
          thread = Thread.new(rqst) do |taking_message|
            msg = taking_message
            ai_option = msg.from.id == @tg_user.id ? :off : $app_config.ai_mode.to_sym
            p "msg.from.id: #{msg.from.id}, @tg_user.id: #{@tg_user.id}, ai_option: #{ai_option}"
            respond_controller = MessageResponder.new(bot: bot, message: msg).build_respond
            p "respond_controller: #{respond_controller}"
            msg_controller = respond_controller.go(ai_mode: ai_option)
          end
          thread.join
          break if respond_controller.command? && msg.from.id == @tg_user.id
          break msg_controller if msg.from.id == @tg_user.id
        end
      end
=end

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
