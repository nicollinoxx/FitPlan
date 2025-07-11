require "test_helper"

class Identity::AvatarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)
  end

  test "should get show and render current avatar if attached" do
    @user.avatar.attach(io: file_fixture("avatar.png").open, filename: "avatar.png", content_type: "image/png")

    get identity_avatar_url(@user)
    assert_response :success
    assert_select "img[src*='#{@user.avatar.filename}']"
    assert_select "form[action='#{identity_avatar_path(@user)}'][method='post']"
  end

  test "should get edit page with preview elements" do
    get edit_identity_avatar_url(@user)
    assert_response :success
    assert_select "form[action='#{identity_avatar_path}']"
    assert_select "input[type=file][name='avatar']"
  end

  test "should update avatar" do
    file = fixture_file_upload("avatar.png", "image/png")

    patch identity_avatar_url(@user), params: { avatar: file }
    assert_redirected_to account_url
    follow_redirect!
    assert_match I18n.t("notice.avatar.update"), response.body
  end

  test "should destroy avatar and redirect" do
    @user.avatar.attach(io: file_fixture("avatar.png").open, filename: "avatar.png", content_type: "image/png")
    assert @user.avatar.attached?

    delete identity_avatar_url(@user)

    assert_redirected_to account_url
    follow_redirect!
    assert_match I18n.t("notice.avatar.destroy"), response.body
  end
end
