# frozen_string_literal: true

class AddColumnLogoutAtInAuthSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :auth_sessions, :logout_at, :timestamp
  end
end
