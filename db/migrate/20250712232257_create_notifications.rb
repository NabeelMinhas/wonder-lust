class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :message, null: false
      t.boolean :read, default: false, null: false

      t.timestamps null: false
    end
  end
end
