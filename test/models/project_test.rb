require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  def setup
    @client = users(:client)
    @pm = users(:pm)
    @video_type = video_types(:highlight_reel)
    
    @project = Project.new(
      name: "Test Project",
      footage_link: "https://example.com/footage",
      status: "in_progress",
      total_price: 299.99,
      client: @client,
      pm: @pm
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @project.valid?
  end

  test "should require name" do
    @project.name = nil
    assert_not @project.valid?
    assert_includes @project.errors[:name], "can't be blank"
  end

  test "should require footage_link" do
    @project.footage_link = nil
    assert_not @project.valid?
    assert_includes @project.errors[:footage_link], "can't be blank"
  end

  test "should require status" do
    @project.status = nil
    assert_not @project.valid?
    assert_includes @project.errors[:status], "can't be blank"
  end

  test "should require total_price" do
    @project.total_price = nil
    assert_not @project.valid?
    assert_includes @project.errors[:total_price], "can't be blank"
  end

  test "should require non-negative total_price" do
    @project.total_price = -10
    assert_not @project.valid?
    assert_includes @project.errors[:total_price], "must be greater than or equal to 0"
  end

  # Association tests
  test "should belong to client" do
    assert_respond_to @project, :client
    assert_equal @client, @project.client
  end

  test "should belong to pm" do
    assert_respond_to @project, :pm
    assert_equal @pm, @project.pm
  end

  test "should have many videos" do
    assert_respond_to @project, :videos
  end

  test "should have many video_types through videos" do
    assert_respond_to @project, :video_types
  end

  test "should have many notifications" do
    assert_respond_to @project, :notifications
  end

  # Scope tests
  test "recent scope should order by created_at desc" do
    @project.save!
    older_project = Project.create!(
      name: "Older Project",
      footage_link: "https://example.com/old",
      status: "completed",
      total_price: 199.99,
      client: @client,
      pm: @pm,
      created_at: 1.day.ago
    )
    
    recent_projects = Project.recent
    assert_equal @project, recent_projects.first
    assert_equal older_project, recent_projects.last
  end

  test "by_status scope should filter by status" do
    @project.save!
    completed_project = Project.create!(
      name: "Completed Project",
      footage_link: "https://example.com/completed",
      status: "completed",
      total_price: 399.99,
      client: @client,
      pm: @pm
    )
    
    in_progress_projects = Project.by_status("in_progress")
    completed_projects = Project.by_status("completed")
    
    assert_includes in_progress_projects, @project
    assert_not_includes in_progress_projects, completed_project
    assert_includes completed_projects, completed_project
    assert_not_includes completed_projects, @project
  end

  test "for_user scope should filter by user_id" do
    @project.save!
    other_client = User.create!(name: "Other Client", email: "other@example.com", role: "client")
    other_project = Project.create!(
      name: "Other Project",
      footage_link: "https://example.com/other",
      status: "draft",
      total_price: 99.99,
      client: other_client,
      pm: @pm
    )
    
    client_projects = Project.for_user(@client.id)
    assert_includes client_projects, @project
    assert_not_includes client_projects, other_project
  end

  # Instance method tests
  test "formatted_price should return formatted price string" do
    assert_equal "$299.00", @project.formatted_price
  end

  test "formatted_price should handle zero price" do
    @project.total_price = 0
    assert_equal "$0.00", @project.formatted_price
  end

  test "video_types_summary should return comma-separated video type names" do
    @project.save!
    @project.videos.create!(video_type: @video_type)
    documentary_type = VideoType.create!(name: "Documentary", price: 599.99, format: "4K")
    @project.videos.create!(video_type: documentary_type)
    
    expected = [@video_type.name, documentary_type.name].join(', ')
    assert_equal expected, @project.video_types_summary
  end

  test "status_color should return correct color for each status" do
    @project.status = "in_progress"
    assert_equal "warning", @project.status_color
    
    @project.status = "completed"
    assert_equal "success", @project.status_color
    
    @project.status = "draft"
    assert_equal "secondary", @project.status_color
  end

  test "days_since_created should calculate days from creation" do
    @project.save!
    assert_equal 0, @project.days_since_created
    
    @project.update!(created_at: 5.days.ago, status: "in_progress")
    assert_equal 5, @project.days_since_created
  end

  # Enum tests
  test "should have correct status enum values" do
    assert_equal "in_progress", Project.statuses["in_progress"]
    assert_equal "completed", Project.statuses["completed"]
    assert_equal "draft", Project.statuses["draft"]
  end

  test "should respond to status query methods" do
    @project.status = "in_progress"
    @project.save!
    assert @project.in_progress?
    assert_not @project.completed?
    assert_not @project.draft?
  end
end
