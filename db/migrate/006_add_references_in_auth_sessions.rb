# frozen_string_literal: true

class AddReferencesInAuthSessions < ActiveRecord::Migration[5.2]
  def change
    add_reference(:auth_sessions, :api_token, foreign_key: true)
  end
end
