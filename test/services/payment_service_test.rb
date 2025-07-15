require "test_helper"

class PaymentServiceTest < ActiveSupport::TestCase
  def setup
    @valid_project_data = {
      project: {
        name: "Test Project",
        footage_link: "https://example.com/footage"
      },
      video_type_ids: [1, 2]
    }
    
    @service = PaymentService.new(@valid_project_data)
  end

  test "should process payment successfully with valid data" do
    result = @service.process_payment
    
    assert_equal "success", result[:status]
    assert_equal "Payment processed successfully", result[:message]
    assert result[:transaction_id].present?
  end

  test "should generate unique transaction IDs" do
    result1 = @service.process_payment
    result2 = @service.process_payment
    
    assert_not_equal result1[:transaction_id], result2[:transaction_id]
  end

  test "should generate transaction ID with correct format" do
    result = @service.process_payment
    transaction_id = result[:transaction_id]
    
    assert_match /^txn_\d+_[a-f0-9]{8}$/, transaction_id
  end

  test "should fail with missing project data" do
    invalid_data = nil
    service = PaymentService.new(invalid_data)
    
    result = service.process_payment
    assert_equal "error", result[:status]
    assert_equal "Payment failed. Please check your payment details.", result[:message]
  end

  test "should fail with missing project details" do
    invalid_data = {
      project: nil,
      video_type_ids: [1, 2]
    }
    service = PaymentService.new(invalid_data)
    
    result = service.process_payment
    assert_equal "error", result[:status]
    assert_equal "Payment failed. Please check your payment details.", result[:message]
  end

  test "should fail with missing video type IDs" do
    invalid_data = {
      project: {
        name: "Test Project",
        footage_link: "https://example.com/footage"
      },
      video_type_ids: nil
    }
    service = PaymentService.new(invalid_data)
    
    result = service.process_payment
    assert_equal "error", result[:status]
    assert_equal "Payment failed. Please check your payment details.", result[:message]
  end

  test "should fail with empty project hash" do
    invalid_data = {
      project: {},
      video_type_ids: [1, 2]
    }
    service = PaymentService.new(invalid_data)
    
    result = service.process_payment
    assert_equal "error", result[:status]
  end

  test "should fail with empty video type IDs array" do
    invalid_data = {
      project: {
        name: "Test Project",
        footage_link: "https://example.com/footage"
      },
      video_type_ids: []
    }
    service = PaymentService.new(invalid_data)
    
    result = service.process_payment
    assert_equal "error", result[:status]
  end

  test "should validate project data structure" do
    service = PaymentService.new(@valid_project_data)
    assert service.send(:valid_payment_data?)
  end

  test "should reject invalid project data structure" do
    invalid_data = { invalid: "data" }
    service = PaymentService.new(invalid_data)
    assert_not service.send(:valid_payment_data?)
  end

  test "should handle string video type IDs" do
    valid_data = {
      project: {
        name: "Test Project",
        footage_link: "https://example.com/footage"
      },
      video_type_ids: ["1", "2"]
    }
    service = PaymentService.new(valid_data)
    
    result = service.process_payment
    assert_equal "success", result[:status]
  end
end
