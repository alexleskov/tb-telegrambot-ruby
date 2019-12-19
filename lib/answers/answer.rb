require './lib/message_sender'

module Teachbase
  module Bot
    class Answer

      def initialize(respond, param)
        raise "No such param '#{param}' for send answer" unless [:chat,:from].include?(param)
        
        @param = param
        @respond = respond
        @first_name = @respond.incoming_data.tg_user.first_name
        @last_name = @respond.incoming_data.tg_user.last_name
      end

    protected
      
      def destination
        @respond.incoming_data.message.public_send(@param) if @respond.incoming_data.message.respond_to? @param
      end
    end
  end
end
