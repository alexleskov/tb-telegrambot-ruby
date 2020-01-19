require './lib/message_sender'
require './models/auth_session'

module Teachbase
  module Bot
    class Answer
      MSG_DESTS = %i[chat from].freeze

      def initialize(appshell, param)
        raise "No such param '#{param}' for send answer" unless MSG_DESTS.include?(param)

        @param = param
        @appshell = appshell
        @respond = appshell.controller.respond
      end

      def user_fullname
        active_authsession = @appshell.data_loader.authsession
        if active_authsession && [active_authsession.user.first_name, active_authsession.user.last_name].none?(nil)
          [active_authsession.user.first_name, active_authsession.user.last_name]
        else
          [@respond.incoming_data.tg_user.first_name, @respond.incoming_data.tg_user.last_name]
        end
      end

      def user_fullname_str
        user_fullname.join(" ")
      end

      protected

      def destination
        @respond.incoming_data.message.public_send(@param) if @respond.incoming_data.message.respond_to? @param
      end
    end
  end
end
