class CreateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.integer :opened_at
      t.boolean :is_publish
      t.boolean :is_available
      t.string :name, null: false
      t.integer :position, null: false
      t.references :course_sessions, foreign_key: true

      t.timestamps
    end
  end
end
