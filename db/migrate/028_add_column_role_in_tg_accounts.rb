# frozen_string_literal: true

class AddColumnRoleInTgAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :tg_accounts, :role, :integer, default: 1, null: false
  end
end
