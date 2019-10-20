class CreateMaterials < ActiveRecord::Migration[5.2]
  def change
    create_table :materials do |t|
      t.string :instance
      t.string :material_name, null: false
      t.integer :category
      t.boolean :markdown
      t.string :source
      t.string :type
      t.references :sections, foreign_key: true

      t.timestamps
    end
  end
end
