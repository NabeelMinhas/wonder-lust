class Project < ApplicationRecord
  # Enums
  enum :status, { in_progress: "in_progress", completed: "completed", draft: "draft" }

  # Associations
  belongs_to :client, class_name: "User", foreign_key: :user_id
  belongs_to :pm, class_name: "User", foreign_key: :pm_id
  has_many :videos, dependent: :destroy
  has_many :video_types, through: :videos
  has_many :notifications, dependent: :destroy

  # Validations
  validates :status, presence: true
  validates :name, presence: true
  validates :footage_link, presence: true
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :with_associations, -> { includes(:client, :pm, :videos, :video_types) }
  
  # Instance methods
  def formatted_price
    "$#{'%.2f' % total_price.to_f}"
  end
  
  def video_types_summary
    video_types.pluck(:name).join(', ')
  end
  
  def status_color
    case status
    when 'in_progress' then 'warning'
    when 'completed' then 'success'
    when 'draft' then 'secondary'
    else 'info'
    end
  end
  
  def days_since_created
    (Date.current - created_at.to_date).to_i
  end
end
