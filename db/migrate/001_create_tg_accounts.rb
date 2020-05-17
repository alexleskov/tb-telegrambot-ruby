# frozen_string_literal: true

class CreateTgAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :tg_accounts do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
