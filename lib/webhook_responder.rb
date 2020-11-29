# frozen_string_literal: true

class WebhookResponder
  attr_reader :message, :bot, :tg_user, :settings

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @tg_user = Teachbase::Bot::TgAccount.find_by(id: find_all_tg_ids_by_webhook_data.first)
    return unless tg_user

    @message.tg_account = tg_user
    @settings = Teachbase::Bot::Setting.find_by(tg_account_id: tg_user.id)
  end

  def detect_type(options = {})
    options[:ai_mode] ||= ai_default_mode
    I18n.with_locale settings.localization.to_sym do
      Teachbase::Bot::Respond.new(self).detect_type(options)
    end
  end

  private

  def find_all_tg_ids_by_webhook_data
    tg_account_ids = []
    user_active_auth_sessions = Teachbase::Bot::AuthSession.active_auth_sessions_by(message.request_body["user_id"])
    user_active_auth_sessions.each do |auth_session|
      tg_account_ids << auth_session.tg_account_id
    end
    tg_account_ids
  end

  def ai_default_mode
    $app_config.ai_mode.to_sym
  end
end
