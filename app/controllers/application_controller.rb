class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user
    # Temporarily fetch the first client user
    # In a real application, this would use proper authentication
    @current_user ||= User.clients.first
  end
  
  def current_user_projects
    Project.for_user(current_user.id)
           .with_associations
           .recent
  end
end
