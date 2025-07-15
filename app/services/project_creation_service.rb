class ProjectCreationService
  def initialize(client, project_params, video_type_ids)
    @client = client
    @project_params = project_params
    @video_type_ids = video_type_ids
  end
  
  def call
    ActiveRecord::Base.transaction do
      create_project
      create_videos
      enqueue_notification
      
      {
        status: "success",
        message: "Project created successfully",
        project: @project,
        redirect_url: Rails.application.routes.url_helpers.project_path(@project)
      }
    end
  rescue => e
    {
      status: "error",
      message: e.message
    }
  end
  
  private
  
  def create_project
    @project = Project.new(@project_params)
    @project.client = @client
    @project.pm = find_available_pm
    @project.status = :in_progress
    @project.total_price = calculate_total_price
    
    unless @project.save
      raise @project.errors.full_messages.join(", ")
    end
  end
  
  def create_videos
    @video_type_ids.each do |video_type_id|
      @project.videos.create!(video_type_id: video_type_id)
    end
  end
  
  def enqueue_notification
    # Create notification in background job instead of synchronously
    NotificationJob.perform_later(
      @project.pm.id,
      @project.id,
      "New project '#{@project.name}' assigned to you"
    )
    
    Rails.logger.info "Notification job enqueued for PM #{@project.pm.name} for project #{@project.name}"
  end
  
  def find_available_pm
    # For now, assign to first PM. In future, implement load balancing
    User.pms.first
  end
  
  def calculate_total_price
    VideoType.where(id: @video_type_ids).sum(:price)
  end
end 