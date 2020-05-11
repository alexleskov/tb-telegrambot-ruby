require './lib/app_shell'
require './lib/answers/answer_menu'
require './lib/answers/answer_text'
require './lib/answers/answer_content'

module Teachbase
  module Bot
    class Controller
      include Formatter
      include Viewers

      MSG_TYPES = %i[text data].freeze

      attr_reader :respond, :answer, :menu, :answer_content, :appshell, :tg_user

      def initialize(params, dest)
        @respond = params[:respond]
        raise "Respond not found" unless respond

        @logger = AppConfigurator.new.get_logger
        @tg_user = respond.incoming_data.tg_user
        @message = respond.incoming_data.message
        @appshell = Teachbase::Bot::AppShell.new(self)
        @answer = Teachbase::Bot::AnswerText.new(appshell, dest)
        @menu = Teachbase::Bot::AnswerMenu.new(appshell, dest)
        @answer_content = Teachbase::Bot::AnswerContent.new(appshell, dest)
      rescue RuntimeError => e
        @logger.debug "Initialization Controller error: #{e}"
        answer.send_out I18n.t('error').to_s
      end

      protected

      def save_message(result_data = {})
        return unless @tg_user || @message
        return if result_data.empty?

        @tg_user.tg_account_messages.create!(result_data)
      end

      def on(command, param, &block)
        raise "No such param '#{param}'. Must be a one of #{MSG_TYPES}" unless MSG_TYPES.include?(param)

        @message_value = case param
                         when :text
                           respond.incoming_data.message.text
                         when :data
                           respond.incoming_data.message.data
                         else
                           raise "Can't find message for #{respond.incoming_data.message}, type: #{param}, available: #{MSG_TYPES}"
                         end

        command =~ @message_value
        if $~
          case block.arity
          when 0
            yield
          when 1
            yield $1
          when 2
            yield $1, $2
          end
        end
      end
    end
  end
end
