# frozen_string_literal: true

class AddUniqueConstraintColumnClientIdInAccounts < ActiveRecord::Migration[5.2]
  def change
    add_index :accounts, %i[client_id tb_id], unique: true
  end
end
