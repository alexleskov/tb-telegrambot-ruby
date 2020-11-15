# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.string :name
      t.string :file_name
      t.string :doc_type
      t.string :url
      t.integer :tb_id, null: false
      t.integer :built_at
      t.integer :edited_at
      t.integer :file_size
      t.integer :folder_id
      t.boolean :is_folder
      t.references :user, foreign_key: true
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end