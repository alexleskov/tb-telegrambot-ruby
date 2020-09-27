# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :tb_user_id
      t.integer :tb_created_at
      t.string :text
      t.string :avatar_url
      t.string :user_name
      t.references :commentable, polymorphic: true

      t.timestamps
    end
  end
end
