# frozen_string_literal: true

class AddColumnActiveInAccountsAndAddDefaultName < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :active, :boolean, default: true, null: false
    change_column_default :accounts, :name, "Undefined"
  end
end
