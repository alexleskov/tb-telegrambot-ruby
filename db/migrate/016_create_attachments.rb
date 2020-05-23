# frozen_string_literal: true

class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :name
      t.string :category
      t.string :url
      t.references :imageable, polymorphic: true

      t.timestamps
    end
  end
end
