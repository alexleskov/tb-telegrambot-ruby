require './controllers/controller'

class Teachbase::Bot::ActionController < Teachbase::Bot::Controller

  def initialize(message_responder)
    super(message_responder)
  end

  def match_data
    on %r{^/start} do
      answer.send_greeting_message
      menu.starting
    end

    on %r{^/close} do
      answer.send_farewell_message
    end

    on %r{^/hide_menu} do
      menu.hide
    end

    on %r{^/sec(\d*)_cs(\d*)} do
      @message_value =~ %r{^/sec(\d*)_cs(\d*)}
      section_id = $1
      course_session_id = $2
      answer.send "#{section_id} #{course_session_id}"
      section_show_materials(section_id, course_session_id)
    end
  end

  private

  def on(command, &block)
    super(command, :text, &block)
  end

end
