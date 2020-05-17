# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :tb_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone
      t.string :password
      t.string :avatar_url, default: "https://image.flaticon.com/icons/png/512/149/149071.png"

      t.timestamps
    end
  end
end
