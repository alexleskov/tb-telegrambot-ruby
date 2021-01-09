# frozen_string_literal: true

class MessageResponder
  include Formatter

  attr_reader :bot, :tg_user, :settings, :first_name, :last_name, :username, :tg_id, :message
  attr_accessor :strategy_class, :ai_mode

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @ai_mode = options[:ai_mode] || $app_config.ai_mode
    fetching_tg_user_data_by(options)
    @tg_user = call_tg_user
    raise "Can't find tg_user" unless tg_user
    
    @settings = Teachbase::Bot::Setting.find_or_create_by!(tg_account_id: tg_user.id)
    @strategy_class = options[:strategy_class] || current_user_strategy_class
  end

  def respond
    I18n.with_locale settings.localization.to_sym do
      Teachbase::Bot::Respond.new(self)
    end
  end

  def current_strategy
     @strategy ||= handle
  end

  def handle
    @strategy = strategy_class.new(respond.init_controller)
  end

  def current_user_interface_class
    to_constantize("Teachbase::Bot::Interfaces::#{to_camelize(strategy_current_class_name)}")
  end

  def current_user_strategy_class
    return strategy_default_class unless strategy_current_class_name

    to_constantize("Teachbase::Bot::Strategies::#{to_camelize(strategy_current_class_name)}")
  end

  protected

  def strategy_default_class
    Teachbase::Bot::Strategies::StandartLearning
  end

  def strategy_current_class_name
    settings.scenario
  end

  private

  def fetching_tg_user_data_by(options)
    message_from = options[:message].from if options[:message] && options[:message].from
    @first_name  = message_from ? message_from.first_name : options[:first_name]
    @last_name   = message_from ? message_from.last_name  : options[:last_name]
    @username    = message_from ? message_from.username   : options[:username]
    @tg_id       = message_from ? message_from.id         : options[:tg_id]
  end

  def call_tg_user
    finded_tg_user = Teachbase::Bot::TgAccount.find_or_create_by!(id: tg_id)
    return finded_tg_user unless first_name && last_name && username

    finded_tg_user.update!(first_name: first_name, last_name: last_name, username: username)
    finded_tg_user
  end
end
