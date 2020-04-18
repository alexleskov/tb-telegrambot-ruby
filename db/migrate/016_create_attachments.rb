class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string :name
      t.string :category
      t.string :url
      t.references :material, foreign_key: true
      t.references :quiz, foreign_key: true
      t.references :task, foreign_key: true
      t.references :scorm_package, foreign_key: true

      t.timestamps
    end
  end
end
