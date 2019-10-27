class CreateMaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :materials do |t|
      t.string :name, null: false
      t.integer :category
      t.boolean :markdown
      t.string :source
      t.string :type
      t.references :section, foreign_key: true
      t.references :course_session, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
