require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sign_up_url
    assert_response :success
  end

  test "should sign up" do
    assert_difference("User.count") do
      post sign_up_url, params: { email: "lazaronixon@hey.com", password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*", name: "lazaronixon" }
    end

    assert_redirected_to sheets_url(format: :html)
  end

  test "should limit sign up attempts" do
    assert_no_difference("User.count") do
      with_rate_limit_exceeded do
        post sign_up_url, params: { email: "lazaronixon@hey.com", password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*", name: "lazaronixon" }
      end
    end

    assert_redirected_to sign_up_url
  end
end
