# frozen_string_literal: true

class AddTgidsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :curator_tg_id, :integer
    add_column :accounts, :support_tg_id, :integer
  end
end
