require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @client = User.new(name: "Test Client", email: "test_client@example.com", role: "client")
    @pm = User.new(name: "Test PM", email: "test_pm@example.com", role: "pm")
  end

  # Validation tests
  test "should be valid with valid attributes" do
    assert @client.valid?
    assert @pm.valid?
  end

  test "should require name" do
    @client.name = nil
    assert_not @client.valid?
    assert_includes @client.errors[:name], "can't be blank"
  end

  test "should require email" do
    @client.email = nil
    assert_not @client.valid?
    assert_includes @client.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    @client.save!
    duplicate_user = User.new(name: "Bob", email: "test_client@example.com", role: "pm")
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should require role" do
    @client.role = nil
    assert_not @client.valid?
    assert_includes @client.errors[:role], "can't be blank"
  end

  # Association tests
  test "should have many projects" do
    assert_respond_to @client, :projects
  end

  test "should have many notifications" do
    assert_respond_to @pm, :notifications
  end

  # Scope tests using fixtures
  test "clients scope should return only clients" do
    clients = User.clients
    assert_includes clients, users(:client)
    assert_includes clients, users(:another_client)
    assert_not_includes clients, users(:pm)
    assert_not_includes clients, users(:another_pm)
  end

  test "pms scope should return only project managers" do
    pms = User.pms
    assert_includes pms, users(:pm)
    assert_includes pms, users(:another_pm)
    assert_not_includes pms, users(:client)
    assert_not_includes pms, users(:another_client)
  end

  # Role tests using fixtures
  test "should identify client role correctly" do
    client = users(:client)
    assert client.client?
    assert_not client.pm?
  end

  test "should identify pm role correctly" do
    pm = users(:pm)
    assert pm.pm?
    assert_not pm.client?
  end
end
