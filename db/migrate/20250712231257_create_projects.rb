class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :footage_link, null: false
      t.decimal :total_price, null: false
      t.string :status, null: false
      t.references :user, null: false, foreign_key: true
      t.integer :pm_id, null: false

      t.timestamps null: false
    end
  end
end
