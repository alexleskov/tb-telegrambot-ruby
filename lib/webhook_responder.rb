# frozen_string_literal: true

class WebhookResponder < MessageResponder
  attr_reader :user_active_auth_sessions

  def initialize(options)
    super(options)
    @message.tg_account = tg_user
  end

  private

  def find_tg_user
    tg_account_ids = []
    @user_active_auth_sessions = find_user_active_auth_sessions
    return if !user_active_auth_sessions || user_active_auth_sessions.empty?

    user_active_auth_sessions.each do |auth_session|
      next unless auth_session.account && auth_session.account.tb_id == message.account_tb_id

      tg_account_ids << auth_session.tg_account_id
    end
    Teachbase::Bot::TgAccount.find_by(id: tg_account_ids.first)
  end

  def find_user_active_auth_sessions
    Teachbase::Bot::AuthSession.active_auth_sessions_by(message.request_body["user_id"])
  end
end
