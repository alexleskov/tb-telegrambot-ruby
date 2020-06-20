# frozen_string_literal: true

class CreateCacheMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :cache_messages do |t|
      t.integer :message_id
      t.string :data
      t.string :text
      t.string :message_type
      t.string :file_id
      t.string :file_size
      t.string :file_type
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
