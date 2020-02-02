require './lib/message_sender'
require './models/auth_session'

module Teachbase
  module Bot
    class Answer
      MSG_DESTS = %i[chat from].freeze

      attr_reader :msg_params

      def initialize(appshell, param)
        raise "No such param '#{param}' for send answer" unless MSG_DESTS.include?(param)

        @param = param
        @appshell = appshell
        @respond = appshell.controller.respond
        @tg_user = @respond.incoming_data.tg_user
        @logger = AppConfigurator.new.get_logger
        @msg_params = {}
      end

      def create(options)
        @msg_params[:text] = options[:text].squeeze(" ")

        raise "Can't find menu destination for message #{@respond.incoming_data}" unless destination
        raise "Option 'text' is missing" unless @msg_params[:text]

        @msg_params[:tg_user] = @tg_user
        @msg_params[:bot] = @respond.incoming_data.bot
        @msg_params[:chat] = destination
      end

      def user_fullname(option) # TODO: move to appshell by DataLoader
        active_authsession = @appshell.data_loader.authsession
        user_name = if active_authsession && [active_authsession.user.first_name, active_authsession.user.last_name].none?(nil)
                      [active_authsession.user.first_name, active_authsession.user.last_name]
                    else
                      [@respond.incoming_data.tg_user.first_name, @respond.incoming_data.tg_user.last_name]
                    end
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
