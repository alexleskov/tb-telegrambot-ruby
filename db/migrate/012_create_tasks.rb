# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.integer :tb_id, null: false
      t.integer :position, null: false
      t.string :name
      t.string :content
      t.string :description
      t.string :title
      t.string :status
      t.boolean :editor_js, default: false
      t.references :section, foreign_key: true
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
