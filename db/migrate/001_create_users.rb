class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :first_name
      t.string :last_name
      t.string :external_id
      t.string :email
      t.string :phone
      t.string :password

      t.timestamps
    end
  end
end
