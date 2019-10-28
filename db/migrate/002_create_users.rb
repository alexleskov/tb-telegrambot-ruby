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
      t.string :avatar_url, default: "https://image.flaticon.com/icons/png/512/149/149071.png"
      t.integer :active_courses_count, default: 0
      t.integer :average_score_percent, default: 0
      t.integer :archived_courses_count, default: 0
      t.integer :total_time_spent, default: 0
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
