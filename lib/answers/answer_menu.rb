# frozen_string_literal: true

require './lib/keyboards/text_command_keyboard'
require './lib/keyboards/inline_callback_keyboard'
require './lib/keyboards/inline_url_keyboard'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::AnswerController
  MENU_TYPES = %i[menu menu_inline hide_kb].freeze

  def create(options)
    super(options)
    buttons = options[:buttons]

    raise "No such menu type: #{options[:type]}" unless MENU_TYPES.include?(options[:type])

    @msg_params[:menu] = options[:type]
    @msg_params[:mode] = options[:mode]
    slices_count = options[:slices_count] || nil

    if options[:type] != :hide_kb
      raise "Buttons must be an Array class. Given '#{buttons.class}'" unless buttons.is_a?(Array)

      @msg_params[:menu_data] = init_menu_params(buttons, slices_count)
    end
    MessageSender.new(msg_params).send
  end

  def show_more(params)
    params.merge!(type: :menu_inline)
    params[:mode] ||= :none
    params[:text] ||= "#{I18n.t('show_more')} (#{params[:all_count] - params[:offset_num]})?"
    params[:buttons] = InlineCallbackKeyboard.collect(buttons: [InlineCallbackButton.more(params)]).raw
    create(params)
  end

  def back(params = {})
    params.merge!(type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [build_back_button]).raw)
    params[:mode] ||= :none
    params[:text] ||= I18n.t('start_menu_message').to_s
    create(params)
  end

  def custom_back(params)
    params.merge!(type: :menu_inline, buttons: InlineCallbackKeyboard.collect(buttons: [build_custom_back_button(params[:callback_data])]).raw)
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

  def confirmation(params)
    params.merge!(type: :menu_inline, slices_count: 2)
    default_title = "<i>#{I18n.t('confirm_action')}</i> #{Emoji.t(:point_down)}"
    params[:text] = params[:text] ? "#{default_title}\n#{params[:text]}" : default_title
    create(params)
  end

  def hide(text)
    create(text: text.to_s, type: :hide_kb)
  end

  private

  def build_back_button
    InlineCallbackButton.back(@msg_params[:tg_user].tg_account_messages)
  end

  def build_custom_back_button(callback_data)
    InlineCallbackButton.custom_back(callback_data)
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
