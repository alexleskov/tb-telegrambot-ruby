require './lib/answers/answer'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::Answer
  def initialize(appshell, param)
    super(appshell, param)
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

  def starting(text = I18n.t('start_menu_message').to_s)
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

  def hide(text)
    raise "Can't find menu destination for message #{@respond.incoming_data}" if destination.nil?

    MessageSender.new(bot: @respond.incoming_data.bot, chat: destination,
                      text: text.to_s, hide_kb: true).send
  end
end
