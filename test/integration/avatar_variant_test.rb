require "test_helper"

class AvatarVariantTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    @user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files/avatar.png")),
                        filename: "avatar.png", content_type: "image/png")
  end

  test "an avatar is served as a variant sized for where it is drawn" do
    sign_in_as(@user)
    get social_profiles_url(query: @user.name)

    assert_response :success
    assert_select "img[width=?][src*=?]", "56", "representations"
    assert_no_match %r{/rails/active_storage/blobs/redirect}, response.body
  end

  test "the list asks for one page instead of every match" do
    30.times { |i| User.create!(name: "Tester #{i}", handle: "tester#{i}", email: "t#{i}@example.com", password: "secret123") }
    sign_in_as(@user)

    get social_profiles_url(query: "Tester")

    assert_response :success
    assert_select "turbo-frame#next_page_container", 1
    assert_operator css_select("div#paginables > div").size, :<, 30
  end
end
