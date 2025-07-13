class CreateVideos < ActiveRecord::Migration[7.2]
  def change
    create_table :videos do |t|
      t.references :project, null: false, foreign_key: true
      t.references :video_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
