# frozen_string_literal: true

class CreateQuizzes < ActiveRecord::Migration[5.2]
  def change
    create_table :quizzes do |t|
      t.integer :tb_id, null: false
      t.integer :position, null: false
      t.integer :questions_count
      t.integer :passing_grade
      t.integer :attempts
      t.integer :available_attempts
      t.integer :time_limit
      t.integer :total_score
      t.integer :attempt_score
      t.integer :success_answers_count
      t.string :grading_method
      t.string :navigation
      t.string :name
      t.string :status
      t.string :source
      t.boolean :completed
      t.boolean :checked
      t.boolean :success
      t.boolean :is_incomplete
      t.boolean :can_pass
      t.boolean :results_available
      t.references :section, foreign_key: true
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
