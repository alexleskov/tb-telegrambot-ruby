# frozen_string_literal: true

class CreateScormPackages < ActiveRecord::Migration[5.2]
  def change
    create_table :scorm_packages do |t|
      t.integer :tb_id, null: false
      t.integer :position, null: false
      t.string :name
      t.string :status
      t.string :source
      t.references :section, foreign_key: true
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
