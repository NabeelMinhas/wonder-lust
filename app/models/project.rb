class Project < ApplicationRecord
  # Enums
  enum status: { in_progress: 0, completed: 1, draft: 2 }

  # Associations
  belongs_to :client, class_name: "User", foreign_key: :user_id
  belongs_to :pm, class_name: "User", foreign_key: :pm_id
  has_many :videos, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Validations
  validates :status, presence: true
  validates :name, presence: true
  validates :footage_link, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
