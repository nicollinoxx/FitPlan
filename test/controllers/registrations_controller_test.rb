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

    assert_redirected_to sign_in_url
  end

  test "should answer the same for an email that is taken" do
    user = users(:lazaro_nixon)

    assert_no_difference("User.count") do
      assert_enqueued_email_with UserMailer, :account_exists, params: { user: user } do
        post sign_up_url, params: { email: user.email, password: "Secret1*3*5*", password_confirmation: "Secret1*3*5*", name: "lazaronixon" }
      end
    end

    assert_redirected_to sign_in_url
    assert_equal "We sent an email to #{user.email} with the next steps", flash[:notice]
  end

  test "should not reveal a taken email alongside other errors" do
    post sign_up_url, params: { email: users(:lazaro_nixon).email, password: "short", password_confirmation: "short", name: "lazaronixon" }

    assert_response :unprocessable_entity
    assert_no_match(/taken/, response.body)
  end
end
