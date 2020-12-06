# frozen_string_literal: true

class AddTgidsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :curator_tg_id, :integer
    add_column :accounts, :support_tg_id, :integer
    change_column_default :accounts, :support_tg_id, from: nil, to: 439_802_952
  end
end
