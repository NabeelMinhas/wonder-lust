require "test_helper"

class VideoTypeTest < ActiveSupport::TestCase
  def setup
    @video_type = VideoType.new(
      name: "Test Video Type",
      price: 299.99,
      format: "16:9 HD (1920x1080)"
    )
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @video_type.valid?
  end

  test "should require name" do
    @video_type.name = nil
    assert_not @video_type.valid?
    assert_includes @video_type.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    @video_type.save!
    duplicate_video_type = VideoType.new(
      name: "Test Video Type",
      price: 199.99,
      format: "Different format"
    )
    assert_not duplicate_video_type.valid?
    assert_includes duplicate_video_type.errors[:name], "has already been taken"
  end

  test "should require price" do
    @video_type.price = nil
    assert_not @video_type.valid?
    assert_includes @video_type.errors[:price], "can't be blank"
  end

  test "should require non-negative price" do
    @video_type.price = -10
    assert_not @video_type.valid?
    assert_includes @video_type.errors[:price], "must be greater than or equal to 0"
  end

  test "should allow zero price" do
    @video_type.price = 0
    assert @video_type.valid?
  end

  test "should require format" do
    @video_type.format = nil
    assert_not @video_type.valid?
    assert_includes @video_type.errors[:format], "can't be blank"
  end

  # Association tests
  test "should have many videos" do
    assert_respond_to @video_type, :videos
  end

  test "should have many projects through videos" do
    assert_respond_to @video_type, :projects
  end

  test "should destroy associated videos when video type is destroyed" do
    @video_type.save!
    project = projects(:wedding_project)
    video = @video_type.videos.create!(project: project)
    
    assert_difference 'Video.count', -1 do
      @video_type.destroy
    end
  end

  # Format tests
  test "should accept various format strings" do
    valid_formats = [
      "16:9 HD (1920x1080)",
      "4K (3840x2160)",
      "1:1 Square (1080x1080)",
      "9:16 Vertical (1080x1920)",
      "Custom format"
    ]
    
    valid_formats.each do |format|
      @video_type.format = format
      assert @video_type.valid?, "Format '#{format}' should be valid"
    end
  end

  # Price tests
  test "should handle decimal prices" do
    @video_type.price = 299.99
    assert @video_type.valid?
  end

  test "should handle whole number prices" do
    @video_type.price = 300
    assert @video_type.valid?
  end

  test "should handle very large prices" do
    @video_type.price = 999999.99
    assert @video_type.valid?
  end
end
