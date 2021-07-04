# frozen_string_literal: true

class ChangeDefaultValueForCourseSessionsIconUrl < ActiveRecord::Migration[5.2]
  def up
    change_column_default :course_sessions, :icon_url, "https://content.tviz.tv/gfx/res/44358/3xlw80g8eu0w8cwc8ocw00cwg.jpg"
  end

  def down
    change_column_default :course_sessions, :icon_url, ""
  end
end
