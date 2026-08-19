require "test_helper"

class RankingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user  = users(:lazaro_nixon)
    @other = users(:lazaro)

    sign_in_as(@user)
  end

  test "should get global" do
    @user.update!(ranking_score: 30)
    @other.update!(ranking_score: 50)

    get global_rankings_url

    assert_response :success
    assert_select "a[href=?]", social_profile_path(@other)
    assert_select "a[href=?]", social_profile_path(@user)
  end

  test "global skips unranked users" do
    @user.update!(ranking_score: 0)
    @other.update!(ranking_score: 0)

    get global_rankings_url

    assert_response :success
    assert_select "a[href=?]", social_profile_path(@user), false
  end

  test "should get friends" do
    get friends_rankings_url

    assert_response :success
    assert_select "a[href=?]", social_profile_path(@other)
    assert_select "a[href=?]", social_profile_path(@user)
  end

  test "global paginates keeping positions across pages" do
    16.times { |index| create_ranked_user(index) }

    get global_rankings_url(page: 2)

    assert_response :success
    assert_select "span", text: "16"
  end

  test "should get global as turbo_stream" do
    @user.update!(ranking_score: 30)

    get global_rankings_url(format: :turbo_stream)

    assert_response :success
    assert_select "turbo-stream[target=?]", "next_page_container"
  end

  test "friends lists the current user even without friends" do
    follows(:two).destroy

    get friends_rankings_url

    assert_response :success
    assert_select "a[href=?]", social_profile_path(@user)
    assert_select "a[href=?]", social_profile_path(@other), false
  end

  private

  def create_ranked_user(index)
    User.create!(name: "ranked#{index}", email: "ranked#{index}@example.com",
                 password: "Secret1*3*5*", ranking_score: 100 - index)
  end
end
