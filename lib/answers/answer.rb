require './lib/message_sender'
require './models/auth_session'

module Teachbase
  module Bot
    class Answer
      MSG_DESTS = %i[chat from].freeze

      attr_reader :buttons, :type, :text, :slices_count

      def initialize(appshell, param)
        raise "No such param '#{param}' for send answer" unless MSG_DESTS.include?(param)

        @param = param
        @appshell = appshell
        @respond = appshell.controller.respond
      end

      def create(options)
        raise "Can't find menu destination for message #{@respond.incoming_data}" if destination.nil?
        @buttons = options[:buttons]
        @type = options[:type]
        @text = options[:text]
        @slices_count = options[:slices_count] || nil
        raise "Option 'text' is missing" unless text
      end

      def user_fullname(option)
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
