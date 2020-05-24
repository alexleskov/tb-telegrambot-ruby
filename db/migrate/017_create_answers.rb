# frozen_string_literal: true

class CreateAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :answers do |t|
      t.integer :tb_id
      t.integer :attempt
      t.string :text
      t.string :status
      t.references :answerable, polymorphic: true

      t.timestamps
    end
  end
end
