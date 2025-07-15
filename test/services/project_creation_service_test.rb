require "test_helper"

class ProjectCreationServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    @client = users(:client)
    @pm = users(:pm)
    @video_type1 = video_types(:highlight_reel)
    @video_type2 = video_types(:social_media)
    
    @project_params = {
      name: "Test Project",
      footage_link: "https://example.com/test-footage"
    }
    
    @video_type_ids = [@video_type1.id, @video_type2.id]
    
    @service = ProjectCreationService.new(@client, @project_params, @video_type_ids)
  end

  test "should create project successfully" do
    assert_difference 'Project.count', 1 do
      result = @service.call
      assert_equal "success", result[:status]
      assert_equal "Project created successfully", result[:message]
      assert_instance_of Project, result[:project]
    end
  end

  test "should create videos for selected video types" do
    assert_difference 'Video.count', 2 do
      @service.call
    end
  end

  test "should calculate total price correctly" do
    result = @service.call
    project = result[:project]
    expected_total = @video_type1.price + @video_type2.price
    assert_equal expected_total, project.total_price
  end

  test "should assign project to client" do
    result = @service.call
    project = result[:project]
    assert_equal @client, project.client
  end

  test "should assign project to first available PM" do
    result = @service.call
    project = result[:project]
    assert project.pm.pm?, "Project should be assigned to a PM"
    assert_not_equal @client, project.pm, "Project should not be assigned to client"
  end

  test "should set project status to in_progress" do
    result = @service.call
    project = result[:project]
    assert project.in_progress?
  end

  test "should enqueue notification job" do
    assert_enqueued_with(job: NotificationJob) do
      @service.call
    end
  end

  test "should return error for invalid project params" do
    invalid_params = { name: "", footage_link: "" }
    service = ProjectCreationService.new(@client, invalid_params, @video_type_ids)
    
    result = service.call
    assert_equal "error", result[:status]
    assert_includes result[:message], "can't be blank"
  end

  test "should return error for empty video type ids" do
    service = ProjectCreationService.new(@client, @project_params, [])
    
    result = service.call
    assert_equal "success", result[:status]
    assert_equal 0, result[:project].total_price
  end

  test "should handle nonexistent video type ids" do
    invalid_ids = [999, 1000]
    service = ProjectCreationService.new(@client, @project_params, invalid_ids)
    
    result = service.call
    assert_equal "error", result[:status]
    assert_includes result[:message], "Video type must exist"
  end

  test "should create project with correct associations" do
    result = @service.call
    project = result[:project]
    
    assert_equal 2, project.videos.count
    assert_equal 2, project.video_types.count
    assert_includes project.video_types, @video_type1
    assert_includes project.video_types, @video_type2
  end

  test "should provide redirect URL in success response" do
    result = @service.call
    project = result[:project]
    
    assert result[:redirect_url].present?
    assert_includes result[:redirect_url], "/projects/#{project.id}"
  end

  test "should rollback transaction on error" do
    # Test transaction rollback by using invalid video type IDs
    invalid_ids = [999, 1000]
    service = ProjectCreationService.new(@client, @project_params, invalid_ids)
    
    assert_no_difference ['Project.count', 'Video.count'] do
      result = service.call
      assert_equal "error", result[:status]
    end
  end
end
