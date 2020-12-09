# frozen_string_literal: true

class MessageResponder
  attr_reader :message, :bot, :tg_user, :settings

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @tg_user = Teachbase::Bot::TgAccount.find_or_create_by!(id: message.from.id)
    @settings = Teachbase::Bot::Setting.find_or_create_by!(tg_account_id: tg_user.id)
    tg_user.update!(first_name: message.from.first_name, last_name: message.from.last_name,
                    username: message.from.username)
  end

  def build_respond
    I18n.with_locale settings.localization.to_sym do
      Teachbase::Bot::Respond.new(self)
    end
  end
end
