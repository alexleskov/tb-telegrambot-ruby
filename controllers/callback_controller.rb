require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller

  def initialize(message_responder)
    super(message_responder, :from)
    @logger = AppConfigurator.new.get_logger
  end

  def match_data
    on %r{^touch} do
      answer.send "Touching"
    end

    on %r{archived_courses} do
      course_sessions_list(:archived)
    end

    on %r{active_courses} do
      course_sessions_list(:active)
    end

    on %r{^cs_info_id:} do
      @message_value =~ %r{^cs_info_id:(\d*)}
      course_session_show_info($1)
    end

    on %r{^cs_id:} do
      @message_value =~ %r{^cs_id:(\d*)}
      sections_show($1)
    end

  end

  private

  def on(command, &block)
    super(command, :data, &block)
  end

end
