# frozen_string_literal: true

require './lib/keyboards/text_command_keyboard'
require './lib/keyboards/inline_callback_keyboard'
require './lib/keyboards/inline_url_keyboard'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::AnswerController
  MENU_TYPES = %i[menu menu_inline].freeze
  CONFIRMATION = %i[accept decline].freeze

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

  def show_more(params)
    params.merge!(type: :menu_inline)
    params[:mode] ||= :none
    params[:text] ||= "#{I18n.t('show_more')} (#{params[:all_count] - params[:offset_num]})?"
    params[:buttons] = InlineCallbackKeyboard.collect(buttons: [build_show_more_button(params)]).raw
    create(params)
  end

  def back(params)
    params.merge!(type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [build_back_button]).raw)
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

  def confirmation(params = {})
    params.merge!(type: :menu_inline, slices_count: 2)
    default_title = "<i>#{I18n.t('confirm_action')}</i> #{Emoji.t(:point_down)}"
    params[:text] = params[:text] ? "#{default_title}\n#{params[:text]}" : default_title
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

  def build_back_button
    InlineCallbackButton.back(@tg_user.tg_account_messages)
  end

  def build_custom_back_button(params)
    InlineCallbackButton.custom_back(params[:callback_data])
  end

  def build_open_url_button(params)
    raise "Can't find source for url" unless params[:object].respond_to?(:source)

    InlineUrlButton.g(button_sign: I18n.t('open').capitalize,
                      url: to_default_protocol(params[:object].source))
  end

  def init_menu_params(buttons, slices_count)
    { buttons: buttons, slices: slices_count }
  end
end
