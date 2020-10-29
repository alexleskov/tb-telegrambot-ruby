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

  def hide(options)
    create(text: options[:text], type: :hide_kb)
  end

  private

  def build_back_button
    InlineCallbackButton.back(@msg_params[:tg_user].tg_account_messages)
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
