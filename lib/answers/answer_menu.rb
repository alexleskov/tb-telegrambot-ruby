require './lib/answers/answer'
require './lib/buttons/inline_callback_button'
require './lib/buttons/inline_url_button'
require './lib/buttons/text_command_button'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::Answer
  MENU_TYPES = %i[menu menu_inline].freeze
  LOCALIZATION_EMOJI = [ Emoji.t(:ru), Emoji.t(:us) ]
  SCENARIO_EMOJI = [Emoji.t(:books), Emoji.t(:bicyclist)]

  def initialize(appshell, param)
    @logger = AppConfigurator.new.get_logger
    super(appshell, param)
  end

  def create(options)
    super(options)
    buttons = options[:buttons]

    raise "No such menu type: #{options[:type]}" unless MENU_TYPES.include?(options[:type])
    raise "Buttons must be an Array class. Given '#{buttons.class}'" unless buttons.is_a?(Array)

    slices_count = options[:slices_count] || nil
    @msg_params[:menu] = options[:type]
    @msg_params[:mode] = options[:mode]
    @msg_params[:menu_data] = init_menu_params(buttons, slices_count)
    MessageSender.new(msg_params).send
  end

  def starting(text = I18n.t('start_menu_message').to_s)
    buttons = TextCommandButton.g(commands: @respond.commands,
                                  buttons_sign: %i[signin settings])
    create(buttons: buttons, type: :menu, text: text, slices_count: 2)
  end

  def after_auth
    buttons = TextCommandButton.g(commands: @respond.commands,
                                  buttons_sign: %i[course_list_l1 show_profile_state settings sign_out])
    create(buttons: buttons, type: :menu, text: I18n.t('start_menu_message'), slices_count: 2)
  end

  def settings
    buttons = InlineCallbackButton.g(buttons_sign: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                     command_prefix: "edit_",
                                     callback_data: %i[settings])
    create(buttons: buttons,
           type: :menu_inline,
           mode: :none,
           text: "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                  \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{I18n.t(to_snakecase(@settings.scenario))}
                  \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{I18n.t(@settings.localization)}",
           slices_count: 1)
  end

  def edit_settings
    buttons = InlineCallbackButton.g(buttons_sign: to_i18n(Teachbase::Bot::Setting::PARAMS),
                                     command_prefix: "settings:",
                                     callback_data: Teachbase::Bot::Setting::PARAMS,
                                     back_button: true,
                                     sent_messages: @tg_user.tg_account_messages)
    create(buttons: buttons,
           type: :menu_inline,
           text: "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>",
           slices_count: 2)
  end

  def more(all_count, offset_count, more_button)
    return unless more_button.is_a?(InlineCallbackButton)
    
    create(buttons: more_button,
           type: :menu_inline,
           mode: :none,
           text: "#{Emoji.t(:point_right)} #{I18n.t('show_more')} (#{all_count - offset_count})?")
  end

  def choosing(type, param_name)
    buttons_sign = to_constantize("#{param_name.upcase}_PARAMS", "Teachbase::Bot::#{type.capitalize}::")
    buttons = InlineCallbackButton.g(buttons_sign: to_i18n(buttons_sign),
                                     command_prefix: "#{param_name.downcase}_param:",
                                     callback_data: buttons_sign,
                                     emoji: to_constantize("#{param_name.upcase}_EMOJI",
                                                           "Teachbase::Bot::AnswerMenu::"),
                                     back_button: true,
                                     sent_messages: @tg_user.tg_account_messages)
    create(buttons: buttons,
           type: :menu_inline,
           text: "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{param_name.downcase}")}</b>",
           slices_count: 2)
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