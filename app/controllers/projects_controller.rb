class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :view_footage]
  
  def index
    @projects = current_user_projects
  end

  def show
    # @project is set by before_action
  end
  
  def view_footage
    # @project is set by before_action
    # This will render the view_footage.html.erb template
  end

  def order_new
    @video_types = VideoType.all
  end

  def create
    result = ProjectCreationService.new(
      current_user,
      project_params,
      params[:video_type_ids]
    ).call
    
    if result[:status] == "success"
      render json: result
    else
      render json: result, status: :unprocessable_entity
    end
  end

  def process_payment
    payment_result = PaymentService.new(payment_params).process_payment
    render json: payment_result
  end

  private

  def set_project
    @project = current_user_projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :footage_link)
  end
  
  def payment_params
    params.permit(:project => [:name, :footage_link], :video_type_ids => [])
  end
end
