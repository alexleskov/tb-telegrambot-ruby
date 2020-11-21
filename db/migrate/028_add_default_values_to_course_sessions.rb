# frozen_string_literal: true

class AddDefaultValuesToCourseSessions < ActiveRecord::Migration[5.2]
  def change
    change_column_default :course_sessions, :rating, from: nil, to: 0.0
  end
end
