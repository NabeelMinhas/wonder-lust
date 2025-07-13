class AddProjectReferenceToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_reference :notifications, :project, foreign_key: true, null: true
  end
end
