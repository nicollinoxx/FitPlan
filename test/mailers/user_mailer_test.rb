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

  test "new_follower leaves links in the follower name out of the email" do
    follow = follows(:two)
    follow.follower.name = "Win $500 https://scam.example"
    follow.follower.save!(validate: false)

    mail = UserMailer.with(follow: follow).new_follower

    assert_equal "Win $500 is now following you on FitPlan", mail.subject
    assert_no_match "scam.example", mail.body.encoded
  end
end
