# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      include Formatter

      STANDART_LEARNING_NAME = "standart_learning"
      MARATHON_MODE_NAME =  "marathon"
      BATTLE_MODE_NAME = "battle"
      DEMO_MODE_NAME = "demo_mode"
      ADMIN_MODE_NAME = "admin"
      LIST = [STANDART_LEARNING_NAME, MARATHON_MODE_NAME, BATTLE_MODE_NAME, DEMO_MODE_NAME, ADMIN_MODE_NAME].freeze
      POLICIES = { admin: 2, member: 1 }.freeze

      attr_reader :controller, :interface, :router, :appshell

      def initialize(controller)
        @controller = controller
        @interface = controller.interface
        @appshell = Teachbase::Bot::AppShell.new(controller)
        @router = Teachbase::Bot::Router.new
      end

      protected

      def with_tg_user_policy(roles)
        policies_ids = []
        roles.each { |role| policies_ids << POLICIES[role.to_sym] }
        policies_ids.compact!
        return interface.sys.text.on_forbidden.show unless policies_ids.include?(controller.context.tg_user.role)

        yield
      end

      def user_reaction
        appshell.controller.take_data
      end

      def build_back_button_data
        { mode: :basic, sent_messages: controller.context.tg_user.tg_account_messages }
      end

      def access_denied?(e)
        e.respond_to?(:http_code) && [401, 403].include?(e.http_code)
      end

      def check_status(mode = :silence)
        text_interface = interface.sys.text
        text_interface.update_status(:in_progress).show
        result = yield

        if mode == :silence && result
          interface.destroy(delete_bot_message: { mode: :last })
          return result
        end

        if result
          text_interface.update_status(:success).show
        else
          text_interface.update_status(:fail).show
        end
        interface.destroy(delete_bot_message: { mode: :previous })
        result
      end

      def on_answer_confirmation(params)
        params[:mode] ||= :last
        params[:type] ||= :reply_markup
        interface.destroy(delete_bot_message: params)
        params[:checker_mode] ||= :default
        if params[:reaction].to_sym == :accept
          result = check_status(params[:checker_mode]) { yield }
          appshell.clear_cached_answers if result
        else
          appshell.clear_cached_answers
          interface.sys.text.declined.show
        end
      end
    end
  end
end
