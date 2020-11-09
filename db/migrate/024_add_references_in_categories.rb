# frozen_string_literal: true

class AddReferencesInCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference(:categories, :account, foreign_key: true)
  end
end
