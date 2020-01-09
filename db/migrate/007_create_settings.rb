class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.string :localization, default: "ru"
      t.string :scenario, default: "StandartLearning"
      t.references :tg_account, foreign_key: true

      t.timestamps
    end
  end
end
