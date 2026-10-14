require "test_helper"

class Social::FollowersMarkingTest < ActionDispatch::IntegrationTest
  setup do
    @me = users(:lazaro_nixon)
    Follow.where(follower: users(:lazaro), followed: @me).destroy_all
    users(:lazaro).follow!(followed: @me)
  end

  # Visiting the list is what marks it seen, so the row has to be decided
  # before the after_action runs.
  test "a follower not looked at yet is named and marked, and only until it is seen" do
    sign_in_as @me

    get followers_social_profile_url(@me)
    assert_response :success
    assert_select "p", text: I18n.t("social.profiles.followers.unseen")
    assert_select ".rounded-circle.border-warning", 1, "o avatar do novo seguidor deveria vir contornado"
    assert_select ".border-warning.border-start", 1, "o card do novo seguidor também fica amarelo"

    get followers_social_profile_url(@me)
    assert_select "p", text: I18n.t("social.profiles.followers.unseen"), count: 0
    assert_select ".rounded-circle.border-warning", 0
  end

  # Turbo asks for a link before it is followed. Doing the marking there emptied
  # the list before the reader ever saw it: everything arrived green.
  test "a link fetched ahead of the click does not mark anything" do
    sign_in_as @me

    get followers_social_profile_url(@me), headers: { "X-Sec-Purpose" => "prefetch" }
    assert_response :success

    get followers_social_profile_url(@me)
    assert_select "p", text: I18n.t("social.profiles.followers.unseen")
    assert_select ".border-warning.border-start", 1, "o prefetch não pode ter consumido a marcação"
  end

  test "the links to the list are not prefetched" do
    sign_in_as @me
    get identity_profile_url

    assert_select "a[href=?][data-turbo-prefetch=false]", followers_social_profile_path(@me)
  end

  test "the realtime notices reach the native apps through the bridge" do
    sign_in_as @me
    follow = Follow.find_by!(followed: @me, follower: users(:lazaro))
    html = ApplicationController.render(partial: "shared/flash_notice/follow_notice",
                                        locals: { follower: follow.follower })

    assert_match "bridge--flash-message", html
  end

  # Without a title of its own the bridge falls back to the element's text,
  # which carries the newlines the template is written with, and the snackbar
  # showed the name on one line and the rest on another.
  test "the snackbar is given the notice as a single line" do
    follow = Follow.find_by!(followed: @me, follower: users(:lazaro))

    [ [ "shared/flash_notice/follow_notice", { follower: follow.follower } ],
      [ "shared/flash_notice/sheet_share_notice", { share: sheet_shares(:one) } ] ].each do |partial, locals|
      html  = ApplicationController.render(partial: partial, locals: locals)
      title = html[/data-bridge-title="([^"]*)"/, 1]

      assert title.present?, "#{partial} deveria declarar o título"
      assert_not title.include?("\n"), "#{partial}: o título chegaria quebrado"
    end
  end

  test "the same partial elsewhere never marks anyone" do
    sign_in_as @me
    get social_profiles_url(query: users(:lazaro).name)

    assert_response :success
    assert_select ".rounded-circle.border-warning", 0
  end
end
