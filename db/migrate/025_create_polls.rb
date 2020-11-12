# frozen_string_literal: true

class CreatePolls < ActiveRecord::Migration[5.2]
  def change
    create_table :polls do |t|
      t.integer :tb_id, null: false
      t.integer :position, null: false
      t.integer :questions_count
      t.string :name
      t.string :status
      t.string :source
      t.string :introduction
      t.string :final_message
      t.boolean :show_introduction
      t.boolean :show_final_message
      t.references :section, foreign_key: true
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
