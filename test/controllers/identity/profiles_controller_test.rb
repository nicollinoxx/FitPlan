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
  end

  test "should update profile" do
    patch identity_profile_url, params: { user: { name: "New Name" } }
    assert_redirected_to identity_profile_url
    follow_redirect!
    assert_match "Profile updated successfully", response.body
    assert_equal "New Name", @user.reload.name
  end

  test "should update handle" do
    patch identity_profile_url, params: { user: { handle: "new-handle" } }
    assert_redirected_to identity_profile_url
    assert_equal "new-handle", @user.reload.handle
  end

  test "rejects duplicate handle" do
    patch identity_profile_url, params: { user: { handle: users(:lazaro).handle } }
    assert_response :unprocessable_entity
  end
end
