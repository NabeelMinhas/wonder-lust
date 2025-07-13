class User < ApplicationRecord
  # Enums
  enum role: { client: 0, pm: 1 }

  # Associations
  has_many :projects, foreign_key: :user_id
  has_many :notifications

  # Scope for roles
  scope :clients, -> { where(role: "client") }
  scope :pms,     -> { where(role: "pm") }

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
end
