class Notification < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :project, optional: true

  # Validations
  validates :message, presence: true
  validates :read, inclusion: { in: [ true, false ] }, allow_nil: false
end
