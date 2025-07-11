require "test_helper"

class UserDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @user_detail = user_details(:one)
    @user = users(:lazaro_nixon)
  end

  test "should get new" do
    get new_user_detail_url
    assert_response :success
  end

  test "should create user_detail" do
    @user_detail.destroy

    assert_difference("UserDetail.count", 1) do
      post user_details_url, params: { user_detail: { height: 180, weight: 75, birth_date: "1990-01-01", gender: "male" } }
    end

    assert_redirected_to user_detail_path(UserDetail.last)
  end

  test "should show user_detail" do
    get user_detail_url(@user_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_detail_url(@user_detail)
    assert_response :success
  end

  test "should update user_detail" do
    patch user_detail_url(@user_detail), params: { user_detail: { height: "1.23", weight: "65.2", birth_date: "19/02/1999", gender: "male" } }
    assert_redirected_to user_detail_path(@user_detail)
  end

  test "should not create user_detail with invalid data" do
    @user_detail.destroy

    assert_no_difference("UserDetail.count") do
      post user_details_url, params: { user_detail: { height: nil } }
    end

    assert_response :unprocessable_entity
  end
end
