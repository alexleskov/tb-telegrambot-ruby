class CreateApiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :api_tokens do |t|
      t.string :version, null: false
      t.string :grant_type, null: false
      t.string :expired_at, null: false
      t.string :value, null: false
      t.boolean :active, default: false, null: false
      t.references :tg_account, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
