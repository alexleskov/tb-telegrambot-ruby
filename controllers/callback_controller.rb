require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :from)
  end

  #   def match_data
  #     on %r{^touch} do
  #       answer.send_out "Touching"
  #     end
  #
  #     on %r{archived_courses} do
  #       logger.debug "YO"
  #       course_sessions_list(:archived)
  #     end
  #
  #     on %r{active_courses} do
  #       course_sessions_list(:active)
  #     end
  #
  #     on %r{update_course_sessions} do
  #       update_course_sessions
  #     end
  #
  #     on %r{^cs_info_id:} do
  #       @message_value =~ %r{^cs_info_id:(\d*)}
  #       course_session_show_info($1)
  #     end
  #
  #     on %r{^cs_id:} do
  #       @message_value =~ %r{^cs_id:(\d*)}
  #       sections_show($1)
  #     end
  #
  #   end

  private

  def on(command, &block)
    super(command, :data, &block)
  end
end
