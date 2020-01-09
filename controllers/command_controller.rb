require './controllers/controller'

class Teachbase::Bot::CommandController < Teachbase::Bot::Controller

  def initialize(params)
    super(params, :chat)
  end

  def push_command
    command = respond.commands.find_by(:value, respond.incoming_data.message.text).key
    raise "Can't respond on such command: #{command}." unless self.respond_to? command

    self.public_send(command)
  end

=begin

      def update_course_sessions
        answer.send_out "<b>#{Emoji.find_by_alias('arrows_counterclockwise').raw}#{I18n.t('updating_data')}</b>"
        course_sessions = data_loader.call_data_course_sessions
        raise "Course sessions update failed" unless course_sessions
        answer.send_out "<i>#{Emoji.find_by_alias('+1').raw}#{I18n.t('updating_success')}</i>"
      end
=end

end
