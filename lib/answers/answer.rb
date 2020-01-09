require './lib/message_sender'
require './models/auth_session'

module Teachbase
  module Bot
    class Answer
      MSG_DESTS = [:chat,:from].freeze

      def initialize(respond, param)
        raise "No such param '#{param}' for send answer" unless MSG_DESTS.include?(param)
        @param = param
        @respond = respond
      end

      def user_fullname
        active_authsession = Teachbase::Bot::AuthSession.find_by(tg_account_id: @respond.incoming_data.tg_user.id, active: true)
        if active_authsession && ![active_authsession.user.first_name, active_authsession.user.last_name].any?(nil)
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
