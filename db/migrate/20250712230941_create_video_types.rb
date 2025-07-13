class CreateVideoTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :video_types do |t|
      t.string :name, null: false
      t.decimal :price, null: false
      t.string :format, null: false

      t.timestamps null: false
    end
  end
end
