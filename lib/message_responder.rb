# frozen_string_literal: true

require './models/bot_message'
require './models/tg_account_message'
require './models/tg_account'
require './models/setting'
require './lib/respond'

class MessageResponder
  attr_reader :message, :bot, :tg_user, :settings

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @tg_user = Teachbase::Bot::TgAccount.find_or_create_by!(id: message.from.id)
    @settings = Teachbase::Bot::Setting.find_or_create_by!(tg_account_id: tg_user.id)
    tg_user.update!(first_name: message.from.first_name, last_name: message.from.last_name)
  end

  def detect_type(options = {})
    options[:ai_mode] ||= ai_default_mode
    I18n.with_locale settings.localization.to_sym do
      Teachbase::Bot::Respond.new(self).detect_type(options)
    end
  end

  private

  def ai_default_mode
    $app_config.ai_mode.to_sym
  end
end
