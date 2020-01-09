require './controllers/controller'

class Teachbase::Bot::ActionController < Teachbase::Bot::Controller

  def initialize(params)
    super(params, :chat)
  end

  def match_data
    on %r{^/start} do
      answer.send_out_greeting_message
      menu.starting
    end

    on %r{^/close} do
      menu.hide("<b>#{answer.user_fullname_str}!</b> #{I18n.t('farewell_message')} :'(")
    end

=begin
    on %r{^/sec(\d*)_cs(\d*)} do
      @message_value =~ %r{^/sec(\d*)_cs(\d*)}
      section_id = $1
      course_session_id = $2
      answer.send_out "#{section_id} #{course_session_id}"
      section_show_materials(section_id, course_session_id)
    end
=end 
  end


  private

  def on(command, &block)
    super(command, :text, &block)
  end

end
