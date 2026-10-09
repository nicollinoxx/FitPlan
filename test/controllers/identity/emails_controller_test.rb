require "test_helper"

class Identity::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  test "should get edit" do
    get edit_identity_email_url
    assert_response :success
  end

  test "should keep the email until the new one is verified" do
    assert_enqueued_emails 1 do
      patch identity_email_url, params: { email: "new_email@hey.com", password_challenge: "Secret1*3*5*" }
    end

    assert_redirected_to identity_settings_url
    assert_equal "lazaronixon@hotmail.com", @user.reload.email
    assert_equal "new_email@hey.com", @user.unconfirmed_email
    assert @user.verified?
  end

  test "should not send a verification email to an email that is taken" do
    assert_no_emails do
      perform_enqueued_jobs { patch identity_email_url, params: { email: users(:lazaro).email, password_challenge: "Secret1*3*5*" } }
    end

    assert_redirected_to identity_settings_url
  end

  test "should not update email with wrong password challenge" do
    patch identity_email_url, params: { email: "new_email@hey.com", password_challenge: "SecretWrong1*3" }

    assert_response :unprocessable_entity
    assert_select "li", /Password challenge is invalid/
  end
end
