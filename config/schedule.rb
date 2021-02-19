# frozen_string_literal: true

Process.setproctitle("tb_bot_schedule")
File.open("./tmp/bot_schedule.pid", "w") do |f|
  f << Process.pid
end

require './application'

scheduler = Rufus::Scheduler.new

scheduler.every '3m', name: "New courses notification" do |job|
  result = Teachbase::Bot::TgAccountMessage.raise_webhook_messages_by(type: "course_stat", event: "created")
  raised_messages_by_tg_users_id = result[:raised].group_by { |raised_message| raised_message.tg_account.id }
  notifications_params = Teachbase::Bot::Helper::Notification.new(raised_messages_by_tg_users_id, :cs).build
  job.kill unless notifications_params

  notifications_params.each do |notify_param|
    I18n.with_locale notify_param[:settings].localization.to_sym do
      Teachbase::Bot::Strategies::Notify.new(notify_param[:controller], type: :cs).about(notify_param[:tb_ids])
    end
    result[:raw].where(tb_id: notify_param[:tb_ids]).destroy_all
  end
end

scheduler.join
