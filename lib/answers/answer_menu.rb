# frozen_string_literal: true

require './lib/keyboards/text_command_keyboard'
require './lib/keyboards/inline_callback_keyboard'
require './lib/keyboards/inline_url_keyboard'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::AnswerController
  MENU_TYPES = %i[menu menu_inline].freeze
  LOCALIZATION_EMOJI = %i[ru us].freeze
  SCENARIO_EMOJI = %i[books bicyclist].freeze
  CONFIRMATION = %i[accept decline].freeze

  def initialize(respond, dest)
    @logger = AppConfigurator.new.load_logger
    super(respond, dest)
  end

  def create(options)
    super(options)
    buttons = options[:buttons]

    raise "No such menu type: #{options[:type]}" unless MENU_TYPES.include?(options[:type])
    raise "Buttons must be an Array class. Given '#{buttons.class}'" unless buttons.is_a?(Array)

    @msg_params[:menu] = options[:type]
    @msg_params[:mode] = options[:mode]
    slices_count = options[:slices_count] || nil
    @msg_params[:menu_data] = init_menu_params(buttons, slices_count)
    MessageSender.new(msg_params).send
  end

  def starting(params = {})
    params.merge!(type: :menu, slices_count: 2)
    params[:text] ||= I18n.t('start_menu_message').to_s
    params[:buttons] = TextCommandKeyboard.g(commands: @respond.commands, buttons_signs: %i[signin settings]).raw
    create(params)
  end

  def after_auth(params = {})
    params.merge!(type: :menu, slices_count: 2)
    params[:text] ||= I18n.t('start_menu_message').to_s
    params[:buttons] = TextCommandKeyboard.g(commands: @respond.commands,
                                             buttons_signs: %i[courses_list show_profile_state settings sign_out]).raw
    create(params)
  end

  def ready(params = {})
    params.merge!(type: :menu, slices_count: 1)
    params[:text] ||= "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_next_answer')} #{Emoji.t(:point_down)}"
    params[:buttons] = TextCommandKeyboard.g(commands: @respond.commands, buttons_signs: %i[ready]).raw
    create(params)
  end

  def settings(params = {})
    params.merge!(text: "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                      \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{I18n.t(to_snakecase(@settings.scenario))}
                      \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{I18n.t(@settings.localization)}",
                  slices_count: 1, type: :menu_inline)
    params[:mode] ||= :none
    params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                                command_prefix: "edit_", buttons_actions: %i[settings]).raw
    p "params[:buttons]: #{params[:buttons]}"
    create(params)
  end

  def edit_settings
    params = { text: "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>", slices_count: 2, type: :menu_inline }
    params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(Teachbase::Bot::Setting::PARAMS),
                                                command_prefix: "settings:",
                                                buttons_actions: Teachbase::Bot::Setting::PARAMS,
                                                back_button: { mode: :basic, sent_messages: @tg_user.tg_account_messages }).raw
    create(params)
  end

  def show_more(params)
    params.merge!(type: :menu_inline, text: "#{I18n.t('show_more')} (#{params[:all_count] - params[:offset_num]})?")
    params[:mode] ||= :none
    params[:buttons] = InlineCallbackKeyboard.collect(buttons: [build_show_more_button(params)]).raw
    create(params)
  end

  def back(params)
    params.merge!(type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [build_back_button(params)]).raw)
    params[:mode] ||= :none
    params[:text] ||= I18n.t('start_menu_message').to_s
    create(params)
  end

  def custom_back(params)
    params.merge!(type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [build_custom_back_button(params)]).raw)
    params[:mode] ||= :none
    params[:text] ||= I18n.t('start_menu_message').to_s
    params[:disable_notification] ||= true
    create(params)
  end

  def open_url_by_object(params = {})
    raise "Must have object for this menu" unless params[:object]

    params.merge!(type: :menu_inline, buttons: InlineUrlKeyboard.collect(buttons: [build_open_url_button(params)]).raw)
    params[:text] ||= params[:object].name
    create(params)
  end

  def sign_in_again
    params = { type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.sign_in]).raw }
    params[:mode] ||= :none
    params[:text] ||= "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
    create(params)
  end

  def choosing(type, param_name, params = {})
    params.merge!(type: :menu_inline, slices_count: 2)
    params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{param_name.downcase}")}</b>"
    buttons_signs = to_constantize("#{param_name.upcase}_PARAMS", "Teachbase::Bot::#{type.capitalize}::")
    params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(buttons_signs),
                                                command_prefix: "#{param_name.downcase}_param:",
                                                buttons_actions: buttons_signs,
                                                emojis: to_constantize("#{param_name.upcase}_EMOJI",
                                                                       "Teachbase::Bot::AnswerMenu::"),
                                                back_button: { mode: :basic, sent_messages: @tg_user.tg_account_messages }).raw
    create(params)
  end

  def confirmation(params = {})
    params.merge!(type: :menu_inline, slices_count: 2)
    params[:text] = params[:text] ? "#{default_title}\n#{params[:text]}" : default_title
    default_title = "<i>#{I18n.t('confirm_action')}</i> #{Emoji.t(:point_down)}"
    params[:buttons] = InlineCallbackKeyboard.g(buttons_signs: to_i18n(CONFIRMATION),
                                                command_prefix: params[:command_prefix],
                                                buttons_actions: CONFIRMATION,
                                                emojis: %i[ok leftwards_arrow_with_hook]).raw
    create(params)
  end

  def hide(text)
    raise "Can't find menu destination for message #{@respond.msg_responder}" if destination.nil?

    MessageSender.new(bot: @respond.msg_responder.bot, chat: destination, text: text.to_s,
                      type: :hide_kb).send
  end

  private

  def build_show_more_button(params)
    InlineCallbackButton.more(command_prefix: "show_#{params[:object_type]}_list:#{params[:state]}",
                              limit: params[:limit_count],
                              offset: params[:offset_num])
  end

  def build_back_button(_params)
    InlineCallbackButton.back(@tg_user.tg_account_messages)
  end

  def build_custom_back_button(params)
    InlineCallbackButton.custom_back(params[:callback_data])
  end

  def build_open_url_button(params)
    InlineUrlButton.g(button_sign: I18n.t('open').capitalize,
                      url: to_default_protocol(params[:object].source))
  end

  def init_menu_params(buttons, slices_count)
    { buttons: buttons, slices: slices_count }
  end
end
