class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :tb_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :password
      t.timestamp :auth_at
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
