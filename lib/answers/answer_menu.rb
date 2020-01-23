require './lib/answers/answer'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::Answer
  MENU_TYPES = %i[menu menu_inline].freeze

  def initialize(appshell, param)
    super(appshell, param)
  end

  def self.create_inline_buttons(buttons_names, command_prefix = "")
    raise "'buttons' must be Array" unless buttons_names.is_a?(Array)

    buttons = []
    buttons_names.each do |button_name|
      button_name.to_s
      buttons << [text: I18n.t(button_name.to_s), callback_data: "#{command_prefix}#{button_name.to_s}"]
    end
    buttons    
  end

  def create(options)
    super(options)
    raise "Buttons is #{buttons.class} but must be an Array" unless buttons.is_a?(Array)
    raise "No such menu type: #{type}" unless MENU_TYPES.include?(type)

    menu_params = { bot: @respond.incoming_data.bot,
                    chat: destination,
                    text: text, type => { buttons: buttons, slices: slices_count } }
    MessageSender.new(menu_params).send
  end

  def starting(text = I18n.t('start_menu_message').to_s)
    buttons = [@respond.commands.show(:signin), @respond.commands.show(:settings)]
    create(buttons: buttons, type: :menu, text: text, slices_count: 2)
  end

  def after_auth
    buttons = [@respond.commands.show(:course_list_l1),
               @respond.commands.show(:show_profile_state),
               @respond.commands.show(:settings),
               @respond.commands.show(:sign_out)]
    create(buttons: buttons, type: :menu, text: I18n.t('start_menu_message'), slices_count: 2)
  end

  def hide(text)
    raise "Can't find menu destination for message #{@respond.incoming_data}" if destination.nil?

    MessageSender.new(bot: @respond.incoming_data.bot, chat: destination,
                      text: text.to_s, hide_kb: true).send
  end
end
