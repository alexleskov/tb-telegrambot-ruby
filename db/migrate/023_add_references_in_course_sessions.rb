# frozen_string_literal: true

class AddReferencesInCourseSessions < ActiveRecord::Migration[5.2]
  def change
    add_reference(:course_sessions, :account, foreign_key: true)
  end
end
