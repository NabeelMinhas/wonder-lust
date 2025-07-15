class NotificationJob < ApplicationJob
  queue_as :default
  
  # Retry job up to 3 times with exponential backoff
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  # Don't retry if user or project is deleted
  discard_on ActiveRecord::RecordNotFound

  def perform(user_id, project_id, message)
    Rails.logger.info "Processing NotificationJob for user_id: #{user_id}, project_id: #{project_id}"
    
    user = User.find(user_id)
    project = Project.find(project_id)
    
    # Validate that user is a PM
    unless user.pm?
      Rails.logger.error "User #{user_id} is not a PM, skipping notification"
      return
    end
    
    # Create the notification
    notification = Notification.create!(
      user: user,
      project: project,
      message: message
    )
    
    Rails.logger.info "✅ Notification created successfully: ID #{notification.id} for user #{user.name} about project #{project.name}"
    
    # In a real app, you might also:
    # - Send an email notification
    # - Push notification to mobile app
    # - Update dashboard counters
    # - Log to analytics
    
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "❌ NotificationJob failed - Record not found: #{e.message}"
    raise e
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "❌ NotificationJob failed - Invalid record: #{e.message}"
    raise e
  rescue => e
    Rails.logger.error "❌ NotificationJob failed with unexpected error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end
