class VideoType < ApplicationRecord
  # Associations
  has_many :videos, dependent: :destroy
  has_many :projects, through: :videos

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :format, presence: true
end
