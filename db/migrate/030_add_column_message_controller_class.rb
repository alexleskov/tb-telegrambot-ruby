# frozen_string_literal: true

class AddColumnMessageControllerClass < ActiveRecord::Migration[5.2]
  def change
    add_column :cache_messages, :message_controller_class, :string
    add_column :tg_account_messages, :message_controller_class, :string
  end
end
