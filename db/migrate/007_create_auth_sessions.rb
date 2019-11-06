class CreateAuthSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_sessions do |t|
      t.integer :tb_id
      t.timestamp :auth_at
      t.boolean :active, default: false, null: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
