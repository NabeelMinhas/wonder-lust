class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string  :name,  null: false
      t.string  :email, null: false
      t.integer :role, default: 0, null: false

      t.timestamps null: false
    end
  end
end
