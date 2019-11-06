require './models/tg_account'
require './lib/respond'

class MessageResponder
  attr_reader :message, :bot, :tg_user

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @tg_user = Teachbase::Bot::TgAccount.find_or_create_by!(id: message.from.id)
    tg_user.update!(first_name: message.from.first_name, last_name: message.from.last_name)
  end

  def respond
    Teachbase::Bot::Respond.new(self).detect_respond_type
  end
end
