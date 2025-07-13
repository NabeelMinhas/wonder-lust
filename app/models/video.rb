class Video < ApplicationRecord
  # Associations
  belongs_to :project
  belongs_to :video_type

  # Validations
  validates :project_id, presence: true
  validates :video_type_id, presence: true
end
