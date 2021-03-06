# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.boolean :is_publish
      t.boolean :is_available
      t.string :name
      t.integer :opened_at
      t.integer :position, null: false
      t.integer :links_count, default: 0
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
