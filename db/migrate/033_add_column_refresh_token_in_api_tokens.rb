# frozen_string_literal: true

class AddColumnRefreshTokenInApiTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :api_tokens, :refresh_token, :string
  end
end
