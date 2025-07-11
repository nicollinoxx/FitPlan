require "test_helper"

class Identity::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)
  end

  test "should get edit" do
    get edit_identity_profile_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='user[name]']"
    assert_select "input[name='user[handle]']"
  end

  test "should update profile with valid data" do
    patch identity_profile_url, params: { user: { name: "New Name", handle: "newhandle" } }
    assert_redirected_to account_url
    follow_redirect!
    assert_match "username updated successfully", response.body
    @user.reload
    assert_equal "New Name", @user.name
    assert_equal "newhandle", @user.handle
  end

  test "should not update profile with invalid data" do
    patch identity_profile_url, params: { user: { name: "", handle: "" } }
    assert_response :unprocessable_entity
    assert_select "div", /error/i
    assert_select "form"
  end
end
