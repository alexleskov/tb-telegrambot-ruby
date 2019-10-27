class AddReferencesInUsersAndTgAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference(:tg_accounts, :user, foreign_key: true)
    add_reference(:users, :api_token, foreign_key: true)
  end
end