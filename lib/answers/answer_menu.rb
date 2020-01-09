require './lib/answers/answer'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::Answer

  def initialize(respond, param)
    super(respond, param)
  end

  def create(buttons, type, text, slices_count = nil)
    raise "'buttons' must be Array" unless buttons.is_a?(Array)
    raise "No such menu type: #{type}" unless %i[menu menu_inline].include?(type)
    raise "Can't find menu destination for message #{@respond.incoming_data}" if destination.nil?

    menu_params = { bot: @respond.incoming_data.bot,
                    chat: destination,
                    text: text, type => { buttons: buttons, slices: slices_count } }
    MessageSender.new(menu_params).send
  end

  def starting(text = "#{I18n.t('start_menu_message')}")
    buttons = [@respond.commands.show(:signin), @respond.commands.show(:settings)]
    create(buttons, :menu, text, 2)
  end

  def after_auth
    buttons = [@respond.commands.show(:course_list_l1),
               @respond.commands.show(:show_profile_state),
               @respond.commands.show(:settings),
               @respond.commands.show(:sign_out)]
    create(buttons, :menu, I18n.t('start_menu_message'), 2)
  end

  def course_sessions_choice
    buttons = [[text: I18n.t('archived_courses').capitalize!, callback_data: "archived_courses"],
               [text: I18n.t('active_courses').capitalize!, callback_data: "active_courses"],
               [text: "#{Emoji.find_by_alias('arrows_counterclockwise').raw} #{I18n.t('update_course_sessions')}", callback_data: "update_course_sessions"]]
    create(buttons, :menu_inline, "#{Emoji.find_by_alias('books').raw}<b>#{I18n.t('show_course_list')}</b>", 2)
  end

  def hide(text)
    raise "Can't find menu destination for message #{@respond.incoming_data}" if destination.nil?
    MessageSender.new(bot: @respond.incoming_data.bot, chat: destination,
                      text: text.to_s, hide_kb: true).send
  end
end
