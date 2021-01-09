# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :tb_id, null: false
      t.string :client_id, null: false
      t.string :client_secret, null: false
      t.string :name
      t.string :logo_url
      t.integer :curator_tg_id
      t.integer :support_tg_id

      t.timestamps
    end
  end
end
