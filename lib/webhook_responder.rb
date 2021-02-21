# frozen_string_literal: true

class WebhookResponder < MessageResponder
  def initialize(options)
    super(options)
    fetching_tg_user_data_by
    @message.tg_account = tg_user
  end

  private

  def fetching_tg_user_data_by(_options = {})
    return unless tg_user

    @first_name  = tg_user.first_name
    @last_name   = tg_user.last_name
    @username    = tg_user.username
    @tg_id       = tg_user.id
  end

  def call_tg_user
    tg_account_ids = []
    user_auth_sessions = find_user_auth_sessions
    return if !user_auth_sessions || user_auth_sessions.empty?

    user_auth_sessions.each do |auth_session|
      next unless auth_session.account && auth_session.account.tb_id == message.webhook.account_tb_id

      tg_account_ids << auth_session.tg_account_id
    end
    Teachbase::Bot::TgAccount.find_by(id: tg_account_ids.first)
  end

  def find_user_auth_sessions
    Teachbase::Bot::AuthSession.by_user_tb_id(message.webhook.payload["data"]["user_id"].to_i)
  end
end
