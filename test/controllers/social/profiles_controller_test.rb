require "test_helper"

class Social::ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user    = users(:lazaro_nixon)
    @profile = users(:lazaro)

    sign_in_as(@user)
  end

  test "should get index" do
    get social_profiles_url
    assert_response :success
  end

  test "should search profiles by query" do
    get social_profiles_url, params: { query: @profile.name }
    assert_response :success
    assert_match @profile.name, response.body
  end

  test "should get show" do
    get social_profile_url(@profile)
    assert_response :success
  end

  test "should follow profile" do
    follows(:one).destroy

    assert_difference "Follow.count", 1 do
      post follow_social_profile_url(@profile)
    end

    assert_redirected_to social_profile_url(@profile)
  end

  test "should unfollow profile" do
    assert_difference "Follow.count", -1 do
      delete unfollow_social_profile_url(@profile)
    end

    assert_redirected_to social_profile_url(@profile)
  end

  test "should get followers" do
    get followers_social_profile_url(@profile)
    assert_response :success
  end

  test "marks own followers as seen when visiting own followers page" do
    assert @user.unseen_followers?

    get followers_social_profile_url(@user)
    assert_not @user.reload.unseen_followers?
  end

  test "does not mark followers as seen when visiting another profile's followers" do
    assert @user.unseen_followers?

    get followers_social_profile_url(@profile)
    assert @user.reload.unseen_followers?
  end

  test "should get followings" do
    get followings_social_profile_url(@profile)
    assert_response :success
  end

  test "back link uses referer when from same site" do
    get social_profile_url(@profile), headers: { "HTTP_REFERER" => social_profiles_url }
    assert_select "a[href='#{social_profiles_url}']"
  end

  test "back link falls back to profiles when referer is current page" do
    get social_profile_url(@profile), headers: { "HTTP_REFERER" => social_profile_url(@profile) }
    assert_select "a[href='#{social_profiles_path}']"
  end

  test "back link falls back to profiles without referer" do
    get social_profile_url(@profile)
    assert_select "a[href='#{social_profiles_path}']"
  end

  test "back link falls back to profiles with external referer" do
    get social_profile_url(@profile), headers: { "HTTP_REFERER" => "https://external.com" }
    assert_select "a[href='#{social_profiles_path}']"
  end
end
