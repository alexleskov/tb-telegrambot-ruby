# frozen_string_literal: true

scheduler = Rufus::Scheduler.new

scheduler.every '2m', name: "New courses notification" do |job|
  cached_messages_by_tg_users = Teachbase::Bot::Cache.extract_by(type: "Teachbase::Bot::Webhook::CourseStat", group_by: :tg_user_id)
  notifications_params = Teachbase::Bot::Helper::Notification.new(cached_messages_by_tg_users, :cs).build
  job.kill unless notifications_params

  notifications_params.each do |notify_param|
    I18n.with_locale notify_param[:settings].localization.to_sym do
      Teachbase::Bot::Strategies::Notify.new(notify_param[:controller], type: :cs).about(notify_param[:tb_ids])
    end
  end
end