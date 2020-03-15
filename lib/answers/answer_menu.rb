require './lib/answers/answer'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::Answer
  MENU_TYPES = %i[menu menu_inline].freeze

  def initialize(appshell, param)
    super(appshell, param)
  end

  def create(options)
    super(options)
    buttons = options[:buttons]
    @logger = AppConfigurator.new.get_logger

    raise "No such menu type: #{options[:type]}" unless MENU_TYPES.include?(options[:type])
    raise "Buttons must be an Array class. Given '#{buttons.class}'" unless buttons.is_a?(Array)

    slices_count = options[:slices_count] || nil
    @msg_params[:menu] = options[:type]
    @msg_params[:mode] = options[:mode]
    @msg_params[:menu_data] = init_menu_params(buttons, slices_count)
    MessageSender.new(msg_params).send
  end

  def starting(text = I18n.t('start_menu_message').to_s)
    buttons_sign = %i[signin settings]
    buttons = MenuButton.t(:text_command, commands: @respond.commands, buttons_sign: buttons_sign)
    @logger.debug "buttons: #{buttons}"
    create(buttons: buttons, type: :menu, text: text, slices_count: 2)
  end

  def after_auth
    buttons_sign = %i[course_list_l1 show_profile_state settings sign_out]
    buttons = MenuButton.t(:text_command, commands: @respond.commands, buttons_sign: buttons_sign)
    create(buttons: buttons, type: :menu, text: I18n.t('start_menu_message'), slices_count: 2)
  end

  def hide(text)
    raise "Can't find menu destination for message #{@respond.incoming_data}" if destination.nil?

    MessageSender.new(bot: @respond.incoming_data.bot, chat: destination,
                      text: text.to_s, type: :hide_kb).send
  end

  private

  def init_menu_params(buttons, slices_count)
    {buttons: buttons, slices: slices_count }
  end

end