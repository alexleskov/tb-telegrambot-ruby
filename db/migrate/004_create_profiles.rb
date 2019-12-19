class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.integer :active_courses_count, default: 0
      t.integer :average_score_percent, default: 0
      t.integer :archived_courses_count, default: 0
      t.integer :total_time_spent, default: 0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
