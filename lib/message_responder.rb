# frozen_string_literal: true

class MessageResponder
  include Formatter

  attr_reader :message, :bot, :tg_user, :settings
  attr_accessor :strategy, :ai_mode

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @ai_mode = options[:ai_mode] || $app_config.ai_mode
    find_tg_user
    raise unless tg_user

    @settings = Teachbase::Bot::Setting.find_or_create_by!(tg_account_id: tg_user.id)
    @strategy = options[:strategy] || current_user_strategy_class
  end

  def respond
    I18n.with_locale settings.localization.to_sym do
      Teachbase::Bot::Respond.new(self, ai_mode: ai_mode)
    end
  end

  def handle
    strategy.new(respond.init_controller)
  end

  def strategy_default_class
    Teachbase::Bot::Strategies::StandartLearning
  end

  def current_strategy_name
    settings.scenario
  end

  def current_user_interface_class
    to_constantize("Teachbase::Bot::Interfaces::#{to_camelize(current_strategy_name)}")
  end

  def current_user_strategy_class
    return strategy_default_class unless current_strategy_name

    to_constantize("Teachbase::Bot::Strategies::#{to_camelize(current_strategy_name)}")
  end

  private

  def find_tg_user
    @tg_user = Teachbase::Bot::TgAccount.find_or_create_by!(id: message.from.id)
    return unless tg_user

    update_tg_user_info
    tg_user
  end

  def update_tg_user_info
    return unless message&.from

    tg_user.update!(first_name: message.from.first_name, last_name: message.from.last_name,
                    username: message.from.username)
  end
end
