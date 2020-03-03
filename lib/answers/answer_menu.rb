require './lib/answers/answer'

class Teachbase::Bot::AnswerMenu < Teachbase::Bot::Answer
  MENU_TYPES = %i[menu menu_inline].freeze

  def initialize(appshell, param)
    super(appshell, param)
  end

  def create(options)
    super(options)
    #raise "Option 'text' is missing" unless options[:text]

    buttons = options[:buttons]
    @logger = AppConfigurator.new.get_logger

    raise "No such menu type: #{options[:type]}" unless MENU_TYPES.include?(options[:type])
    raise "Buttons is #{buttons.class} but must be an Array" unless buttons.is_a?(Array)

    slices_count = options[:slices_count] || nil
    @msg_params[:menu_type] = options[:type]
    @msg_params[:mode] = options[:mode]
    @msg_params[:menu_data] = init_menu_params(buttons, slices_count)
    MessageSender.new(msg_params).send
  end

  def inline_buttons(buttons_names, command_prefix = "")
    buttons = []
    buttons_names.each do |button_name|
      button_name.to_s
      buttons << [text: I18n.t(button_name.to_s), callback_data: "#{command_prefix}#{button_name.to_s}"]
    end
    buttons
  end

  def inline_nums_buttons(numbers, options = {})
    raise "Can't find numbers for 'num_navigation'" unless numbers

    num_buttons = []
    text = options[:text]
    type = options[:type] || :menu_inline
    prefix = options[:prefix] || ""
    back_button = options[:back_button] || false
    numbers.each_with_index { |item, i| num_buttons << i.to_s }

    buttons = inline_buttons(num_buttons, prefix)
    buttons << inline_back_button if back_button
    create(buttons: buttons,
           type: type,
           text: text,
           slices_count: num_buttons.size)
  end

  def inline_back_button
    callback = cb_for_back_button
    return unless callback

    [text: "#{Emoji.t(:arrow_left)} #{I18n.t('back')}", callback_data: callback]
  end


  def inline_more_button(options)
    text = options[:text] || ""
    sum = options[:sum]
    limit = options[:limit]
    offset = options[:offset]
    cb_prefix = options[:cb_prefix]
    callback = cb_for_more_button(cb_prefix, limit, offset)
    return unless callback

    button = [ text: "#{Emoji.t(:arrow_double_down)} #{I18n.t('show_more')} #{text}",
           callback_data: callback ]
    create(buttons: [button],
           type: :menu_inline,
           mode: :none,
           text: "#{I18n.t('show_more')} (#{sum - offset})?")
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
                      text: text.to_s, type: :hide_kb).send
  end

  private

  def cb_for_more_button(prefix, limit, offset)
    "#{prefix}_lim:#{limit}_offset:#{offset}"
  end

  def cb_for_back_button
    callbacks = @tg_user.tg_account_messages.order(created_at: :desc).where(message_type: "callback_data").select(:data)
    raise "Can't find callbacks for back button" unless callbacks

    return callbacks.first.data if callbacks.size == 1

    callbacks.size.times do |i|
      break callbacks[i + 1].data if callbacks[i + 1].data != callbacks[i].data
    end
  end

  def init_menu_params(buttons, slices_count)
    {buttons: buttons, slices: slices_count }
  end

end