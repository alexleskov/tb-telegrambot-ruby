# frozen_string_literal: true

class CreateMaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :materials do |t|
      t.integer :tb_id, null: false
      t.integer :position, null: false
      t.integer :time_spent
      t.string :name
      t.string :content_type
      t.string :category
      t.string :source
      t.string :status
      t.boolean :editor_js, default: false
      t.boolean :markdown, default: false
      t.jsonb :content, default: '{}'
      t.references :section, foreign_key: true
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
