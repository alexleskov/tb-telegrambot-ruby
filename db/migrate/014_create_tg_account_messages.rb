# frozen_string_literal: true

class CreateTgAccountMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :tg_account_messages do |t|
      t.integer :message_id
      t.jsonb :data
      t.string :message_type
      t.string :file_id
      t.string :file_size
      t.string :file_type
      t.string :message_controller_class
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
