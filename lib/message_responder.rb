# frozen_string_literal: true

class MessageResponder
  include Formatter

  attr_reader :message, :bot, :tg_user, :settings
  attr_accessor :strategy_class, :ai_mode

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @ai_mode = options[:ai_mode] || $app_config.ai_mode
    @tg_user = find_tg_user
    raise "Can't find tg_user" unless tg_user

    @settings = Teachbase::Bot::Setting.find_or_create_by!(tg_account_id: tg_user.id)
    @strategy_class = options[:strategy_class] || current_user_strategy_class
  end

  def respond
    I18n.with_locale settings.localization.to_sym do
      Teachbase::Bot::Respond.new(self, ai_mode: ai_mode)
    end
  end

  def current_strategy
     @strategy ||= handle
  end

  def handle
    p "HANDLE HERE"
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

  def find_tg_user
    finded_tg_user = Teachbase::Bot::TgAccount.find_or_create_by!(id: message.from.id)
    update_tg_user_info(finded_tg_user)
    finded_tg_user
  end

  def update_tg_user_info(tg_user_on_update)
    return unless message&.from

    tg_user_on_update.update!(first_name: message.from.first_name, last_name: message.from.last_name,
                              username: message.from.username)
  end
end
