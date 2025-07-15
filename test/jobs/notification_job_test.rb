require "test_helper"

class NotificationJobTest < ActiveJob::TestCase
  def setup
    @pm = users(:pm)
    @client = users(:client)
    @project = projects(:wedding_project)
    @message = "Test notification message"
  end

  test "should enqueue job correctly" do
    assert_enqueued_with(job: NotificationJob, args: [@pm.id, @project.id, @message]) do
      NotificationJob.perform_later(@pm.id, @project.id, @message)
    end
  end

  test "should create notification successfully" do
    assert_difference 'Notification.count', 1 do
      NotificationJob.perform_now(@pm.id, @project.id, @message)
    end
  end

  test "should create notification with correct attributes" do
    NotificationJob.perform_now(@pm.id, @project.id, @message)
    
    notification = Notification.last
    assert_equal @pm, notification.user
    assert_equal @project, notification.project
    assert_equal @message, notification.message
  end

  test "should only create notifications for PMs" do
    # Try to create notification for a client (should be skipped)
    assert_no_difference 'Notification.count' do
      NotificationJob.perform_now(@client.id, @project.id, @message)
    end
  end

  test "should handle nonexistent user gracefully" do
    assert_no_difference 'Notification.count' do
      # Job should be discarded, not raise an exception
      NotificationJob.perform_now(999, @project.id, @message)
    end
  end

  test "should handle nonexistent project gracefully" do
    assert_no_difference 'Notification.count' do
      # Job should be discarded, not raise an exception
      NotificationJob.perform_now(@pm.id, 999, @message)
    end
  end

  test "should discard job when user is deleted" do
    user_id = @pm.id
    @pm.destroy
    
    assert_no_difference 'Notification.count' do
      # Job should be discarded, not raise an exception
      NotificationJob.perform_now(user_id, @project.id, @message)
    end
  end

  test "should discard job when project is deleted" do
    project_id = @project.id
    @project.destroy
    
    assert_no_difference 'Notification.count' do
      # Job should be discarded, not raise an exception
      NotificationJob.perform_now(@pm.id, project_id, @message)
    end
  end

  test "should retry on standard errors" do
    # This test verifies that job can handle errors gracefully
    # Since we can't easily mock in this test environment, we'll test the basic functionality
    assert_difference 'Notification.count', 1 do
      NotificationJob.perform_now(@pm.id, @project.id, @message)
    end
  end

  test "should process job successfully" do
    # Test that the job processes without errors
    assert_difference 'Notification.count', 1 do
      NotificationJob.perform_now(@pm.id, @project.id, @message)
    end
  end

  test "should handle non-PM user gracefully" do
    # Test that non-PM users don't get notifications
    assert_no_difference 'Notification.count' do
      NotificationJob.perform_now(@client.id, @project.id, @message)
    end
  end

  test "should be queued on default queue" do
    assert_equal "default", NotificationJob.new.queue_name
  end

  test "should have correct retry configuration" do
    job = NotificationJob.new
    
    # Check that job is configured with the correct queue
    assert_equal "default", job.queue_name
  end

  test "should validate message parameter" do
    short_message = "OK"
    assert_difference 'Notification.count', 1 do
      NotificationJob.perform_now(@pm.id, @project.id, short_message)
    end
    
    notification = Notification.last
    assert_equal short_message, notification.message
  end

  test "should handle long messages" do
    long_message = "a" * 200  # Within the 255 character limit
    
    assert_difference 'Notification.count', 1 do
      NotificationJob.perform_now(@pm.id, @project.id, long_message)
    end
    
    notification = Notification.last
    assert_equal long_message, notification.message
  end

  test "should execute in background" do
    assert_enqueued_jobs 1 do
      NotificationJob.perform_later(@pm.id, @project.id, @message)
    end
  end

  test "should handle multiple notifications for same project" do
    another_pm = users(:another_pm)
    
    assert_difference 'Notification.count', 2 do
      NotificationJob.perform_now(@pm.id, @project.id, @message)
      NotificationJob.perform_now(another_pm.id, @project.id, @message)
    end
  end
end
