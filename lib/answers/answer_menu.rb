# frozen_string_literal: true

require './lib/buttons/inline_callback_button'
require './lib/buttons/inline_url_button'
require './lib/buttons/text_command_button'

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
    params.merge!({ type: :menu, slices_count: 2 })
    params[:text] ||= I18n.t('start_menu_message').to_s
    params[:buttons] = TextCommandButton.g(commands: @respond.commands,
                                           buttons_sign: %i[signin settings])
    create(params)
  end

  def after_auth(params = {})
    params.merge!({ type: :menu, slices_count: 2 })
    params[:text] ||= I18n.t('start_menu_message').to_s
    params[:buttons] = TextCommandButton.g(commands: @respond.commands,
                                           buttons_sign: %i[courses_list show_profile_state settings sign_out])
    create(params)
  end

  def ready(params = {})
    params.merge!({ type: :menu, slices_count: 1 })
    params[:text] ||= "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_next_answer')} #{Emoji.t(:point_down)}"
    params[:buttons] = TextCommandButton.g(commands: @respond.commands,
                                           buttons_sign: %i[ready])
    create(params)
  end

  def settings(params = {})
    params.merge!({ text: "<b>#{Emoji.t(:wrench)}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
                      \n #{Emoji.t(:video_game)} #{I18n.t('scenario')}: #{I18n.t(to_snakecase(@settings.scenario))}
                      \n #{Emoji.t(:ab)} #{I18n.t('localization')}: #{I18n.t(@settings.localization)}",
                    slices_count: 1, type: :menu_inline })
    params[:mode] ||= :none
    params[:buttons] = InlineCallbackButton.g(buttons_sign: ["#{I18n.t('edit')} #{I18n.t('settings').downcase}"],
                                     command_prefix: "edit_",
                                     callback_data: %i[settings])
    create(params)
  end

  def edit_settings
    params = { text: "<b>#{Emoji.t(:wrench)} #{I18n.t('editing_settings')}</b>", slices_count: 2, type: :menu_inline }
    params[:buttons] = InlineCallbackButton.g(buttons_sign: to_i18n(Teachbase::Bot::Setting::PARAMS),
                                              command_prefix: "settings:",
                                              callback_data: Teachbase::Bot::Setting::PARAMS,
                                              back_button: true,
                                              sent_messages: @tg_user.tg_account_messages)
    create(params)
  end

  def show_more(params)
    params.merge!({ type: :menu_inline, text: "#{I18n.t('show_more')} (#{params[:all_count] - params[:offset_num]})?" })
    params[:mode] ||= :none
    params[:buttons] = InlineCallbackButton.more(command_prefix: "show_#{params[:object_type]}_list:#{params[:state]}",
                                            limit: params[:limit_count],
                                            offset: params[:offset_num])
    create(params)
  end

  def back(params)
    params.merge!({ type: :menu_inline, buttons: InlineCallbackButton.back(@tg_user.tg_account_messages) })
    params[:mode] ||= :none
    params[:text] ||= "#{I18n.t('start_menu_message')}"
    create(params)
  end

  def custom_back(params)
    params.merge!({ type: :menu_inline, buttons: InlineCallbackButton.custom_back(params[:callback_data]) })
    params[:mode] ||= :none
    params[:text] ||= "#{I18n.t('start_menu_message')}"
    params[:disable_notification] ||= true
    create(params)
  end

  def open_url_by_object(params = {})
    raise "Must have object for this menu" unless params[:object]

    params.merge!({ type: :menu_inline, buttons: InlineUrlButton.g(buttons_sign: [I18n.t('open').capitalize],
                                                              url: [to_default_protocol(params[:object].source)]) })
    params[:text] ||= params[:object].name
    create(params)
  end

  def sign_in_again
    params = { type: :menu_inline, buttons: InlineCallbackButton.sign_in }
    params[:mode] ||= :none
    params[:text] ||= "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
    create(params)
  end

  def choosing(type, param_name, params = {})
    buttons_sign = to_constantize("#{param_name.upcase}_PARAMS", "Teachbase::Bot::#{type.capitalize}::")
    params.merge!({ type: :menu_inline, slices_count: 2 })
    params[:text] ||= "<b>#{Emoji.t(:wrench)} #{I18n.t("choose_#{param_name.downcase}")}</b>"
    params[:buttons] = InlineCallbackButton.g(buttons_sign: to_i18n(buttons_sign),
                                              command_prefix: "#{param_name.downcase}_param:",
                                              callback_data: buttons_sign,
                                              emoji: to_constantize("#{param_name.upcase}_EMOJI",
                                                                    "Teachbase::Bot::AnswerMenu::"),
                                              back_button: true,
                                              sent_messages: @tg_user.tg_account_messages)
    create(params)
  end

  def confirmation(params = {})
    default_title = "<i>#{I18n.t('confirm_action')}</i> #{Emoji.t(:point_down)}"
    params.merge!({ type: :menu_inline, slices_count: 2 })
    params[:text] = params[:text] ? "#{default_title}\n#{params[:text]}" : default_title
    params[:buttons] = InlineCallbackButton.g(buttons_sign: to_i18n(CONFIRMATION),
                                              command_prefix: params[:command_prefix] || "",
                                              callback_data: CONFIRMATION,
                                              emoji: %i[ok leftwards_arrow_with_hook])
    create(params)
  end

  def declined(params)
    return unless params[:back_button]

    params[:text] ||= "#{Emoji.t(:leftwards_arrow_with_hook)} <i>#{I18n.t('declined')}</i>"
    case params[:back_button]
    when :custom_back
      custom_back(params)
    when :back
      back(params)
    end
  end

  def hide(text)
    raise "Can't find menu destination for message #{@respond.msg_responder}" if destination.nil?

    MessageSender.new(bot: @respond.msg_responder.bot, chat: destination,
                      text: text.to_s, type: :hide_kb).send
  end

  private

  def init_menu_params(buttons, slices_count)
    { buttons: buttons, slices: slices_count }
  end
end
