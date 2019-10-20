require './controllers/controller'

class Teachbase::Bot::CallbackController < Teachbase::Bot::Controller

  def initialize(message_responder)
    super(message_responder, :from)
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
      course_session_open($1)
    end

    on %r{^cs_sec_id:} do
      @message_value =~ %r{^cs_sec_id:(\d*)}
      course_session_id = $1
      answer.send "*#{I18n.t('enter_number_of')} #{I18n.t('section2')}:*\n_#{I18n.t('section_show_hint')}_"
      take_data
    end

  end

  private

  def on(command, &block)
    super(command, :data, &block)
  end

end
