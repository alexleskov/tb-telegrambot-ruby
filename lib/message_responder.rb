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

  def respond
    Teachbase::Bot::Respond.new(self).detect_type
  end
end
