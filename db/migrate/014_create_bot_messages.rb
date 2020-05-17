# frozen_string_literal: true

class CreateBotMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_messages do |t|
      t.integer :message_id, null: false
      t.integer :chat_id, null: false
      t.integer :date, null: false
      t.integer :edit_date
      t.string :text, null: false
      t.jsonb :inline_keyboard, default: '{}'
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
