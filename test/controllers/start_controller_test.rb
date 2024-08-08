require "test_helper"

class StartControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(users(:lazaro_nixon))
    get root_url
    assert_response :success
  end
end
