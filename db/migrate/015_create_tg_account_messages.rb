# frozen_string_literal: true

class CreateTgAccountMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :tg_account_messages do |t|
      t.integer :message_id
      t.string :data
      t.string :text
      t.string :message_type
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
