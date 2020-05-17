# frozen_string_literal: true

class CreateAuthSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_sessions do |t|
      t.timestamp :auth_at
      t.boolean :active, default: false, null: false
      t.references :user, foreign_key: true
      t.references :tg_account, foreign_key: true
      t.timestamps
    end
  end
end
