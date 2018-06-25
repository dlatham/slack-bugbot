require 'test_helper'

class BugControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get bug_new_url
    assert_response :success
  end

  test "should get comment" do
    get bug_comment_url
    assert_response :success
  end

  test "should get status" do
    get bug_status_url
    assert_response :success
  end

end
