require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:lazaro_nixon)
  end

  test "password_reset" do
    mail = UserMailer.with(user: @user).password_reset
    assert_equal "Reset your password", mail.subject
    assert_equal [@user.email], mail.to
  end

  test "email_verification" do
    mail = UserMailer.with(user: @user).email_verification
    assert_equal "Verify your email", mail.subject
    assert_equal [@user.email], mail.to
  end

  test "new_follower" do
    follow = follows(:two)
    mail   = UserMailer.with(follow: follow).new_follower

    assert_equal [ follow.followed.email ], mail.to
    assert_equal "#{follow.follower.name} is now following you on FitPlan", mail.subject
  end
end
