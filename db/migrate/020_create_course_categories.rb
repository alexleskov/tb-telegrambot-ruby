# frozen_string_literal: true

class CreateCourseCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :course_categories do |t|
      t.references :course_session, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
