require "test_helper"

class ProjectCreationFlowTest < ActionDispatch::IntegrationTest
  def setup
    @client = users(:client)
    @pm = users(:pm)
    @video_type1 = video_types(:highlight_reel)
    @video_type2 = video_types(:social_media)
  end

  test "should display order new page with video types" do
    get order_new_projects_path
    assert_response :success
    
    assert_select "h1", "Create Your Video Project"
    assert_select ".video-type-card", count: VideoType.count
    assert_select ".video-type-card[data-video-type-id='#{@video_type1.id}']"
    assert_select ".video-type-card[data-video-type-id='#{@video_type2.id}']"
  end

  test "should create project via payment process" do
    project_data = {
      project: {
        name: "Integration Test Project",
        footage_link: "https://example.com/test-footage"
      },
      video_type_ids: [@video_type1.id, @video_type2.id]
    }

    # First, process payment
    post process_payment_projects_path, params: project_data, as: :json
    assert_response :success
    
    payment_response = JSON.parse(response.body)
    assert_equal "success", payment_response["status"]
    assert_equal "Payment processed successfully", payment_response["message"]
    assert payment_response["transaction_id"].present?

    # Then create the project
    assert_difference 'Project.count', 1 do
      assert_difference 'Video.count', 2 do
        post projects_path, params: project_data, as: :json
      end
    end

    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal "success", response_data["status"]
    assert_equal "Project created successfully", response_data["message"]
    assert response_data["redirect_url"].present?
    
    # Verify project was created correctly
    project = Project.last
    assert_equal "Integration Test Project", project.name
    assert_equal "https://example.com/test-footage", project.footage_link
    assert_equal @client, project.client
    assert project.pm.pm?, "Project should be assigned to a PM"
    assert project.in_progress?
    
    # Verify videos were created
    assert_equal 2, project.videos.count
    assert_includes project.video_types, @video_type1
    assert_includes project.video_types, @video_type2
    
    # Verify total price calculation
    expected_total = @video_type1.price + @video_type2.price
    assert_equal expected_total, project.total_price
  end

  test "should enqueue notification job during project creation" do
    project_data = {
      project: {
        name: "Notification Test Project",
        footage_link: "https://example.com/notification-test"
      },
      video_type_ids: [@video_type1.id]
    }

    assert_enqueued_with(job: NotificationJob) do
      post projects_path, params: project_data, as: :json
    end
  end

  test "should handle validation errors gracefully" do
    invalid_project_data = {
      project: {
        name: "",
        footage_link: ""
      },
      video_type_ids: []
    }

    assert_no_difference 'Project.count' do
      post projects_path, params: invalid_project_data, as: :json
    end

    assert_response :unprocessable_entity
    
    response_data = JSON.parse(response.body)
    assert_equal "error", response_data["status"]
    assert_includes response_data["message"], "can't be blank"
  end

  test "should display project details after creation" do
    project = projects(:wedding_project)
    
    get project_path(project)
    assert_response :success
    
    assert_select "h1", project.name
    assert_select "p", text: /#{project.pm.name}/
    assert_select "p", text: project.formatted_price
    assert_select "a[href='#{project.footage_link}']", "View Footage"
  end

  test "should display projects list" do
    get projects_path
    assert_response :success
    
    assert_select "h1", "Your Video Projects"
    assert_select ".project-card", count: Project.for_user(@client.id).count
  end

  test "should redirect to projects after successful creation" do
    project_data = {
      project: {
        name: "Redirect Test Project",
        footage_link: "https://example.com/redirect-test"
      },
      video_type_ids: [@video_type1.id]
    }

    post projects_path, params: project_data, as: :json
    assert_response :success
    
    response_data = JSON.parse(response.body)
    project = Project.last
    assert_includes response_data["redirect_url"], "/projects/#{project.id}"
  end

  test "should calculate correct total price for multiple video types" do
    project_data = {
      project: {
        name: "Price Test Project",
        footage_link: "https://example.com/price-test"
      },
      video_type_ids: [@video_type1.id, @video_type2.id]
    }

    post projects_path, params: project_data, as: :json
    assert_response :success
    
    project = Project.last
    expected_total = @video_type1.price + @video_type2.price
    assert_equal expected_total, project.total_price
  end

  test "should handle empty video type selection" do
    project_data = {
      project: {
        name: "Empty Video Types Project",
        footage_link: "https://example.com/empty-test"
      },
      video_type_ids: []
    }

    post projects_path, params: project_data, as: :json
    assert_response :success
    
    project = Project.last
    assert_equal 0, project.total_price
    assert_equal 0, project.videos.count
  end

  test "should assign project to first available PM" do
    project_data = {
      project: {
        name: "PM Assignment Test",
        footage_link: "https://example.com/pm-test"
      },
      video_type_ids: [@video_type1.id]
    }

    post projects_path, params: project_data, as: :json
    assert_response :success
    
    project = Project.last
    assert project.pm.pm?, "Project should be assigned to a PM"
  end

  test "should create project with in_progress status" do
    project_data = {
      project: {
        name: "Status Test Project",
        footage_link: "https://example.com/status-test"
      },
      video_type_ids: [@video_type1.id]
    }

    post projects_path, params: project_data, as: :json
    assert_response :success
    
    project = Project.last
    assert project.in_progress?
  end
end
