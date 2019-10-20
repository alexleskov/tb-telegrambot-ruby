class CreateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.string :instance
      t.string :part_name, null: false
      t.integer :position, null: false
      t.references :course_sessions, foreign_key: true

      t.timestamps
    end
  end
end
