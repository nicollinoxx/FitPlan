require "test_helper"

class UserTest < ActiveSupport::TestCase
  # avatar --------------------------------------------------------------------

  test "rejects an avatar over the size limit" do
    user = users(:lazaro_nixon)
    user.avatar.attach(io: StringIO.new("x" * 5.megabytes), filename: "big.png", content_type: "image/png")

    assert_not user.valid?
    assert_predicate user.errors[:avatar], :any?
  end

  # handle --------------------------------------------------------------------

  test "generates handle on create" do
    user = User.create!(name: "Jane Doe", email: "jane@example.com", password: "Secret1*3*5*")
    assert_match(/\Ajane-doe-[0-9a-f]{8}\z/, user.handle)
  end

  test "generates unique handles for users with the same name" do
    user1 = User.create!(name: "Same Name", email: "same1@example.com", password: "Secret1*3*5*")
    user2 = User.create!(name: "Same Name", email: "same2@example.com", password: "Secret1*3*5*")
    assert_not_equal user1.handle, user2.handle
  end

  test "handle must be unique on update" do
    user = users(:lazaro_nixon)
    user.handle = users(:lazaro).handle
    assert_not user.valid?
  end

  test "handle format is validated when the handle changes" do
    user = users(:lazaro_nixon)
    user.handle = "invalid_handle"

    assert_not user.valid?(:update)
    assert user.errors[:handle].any?
  end

  test "unrelated updates skip handle validation for legacy handles" do
    user = users(:lazaro_nixon)
    user.update_column(:handle, "legacy_handle")

    assert user.reload.update(name: "Renamed")
  end

  test "to_param returns handle" do
    assert_equal users(:lazaro_nixon).handle, users(:lazaro_nixon).to_param
  end

  # search --------------------------------------------------------------------

  test "search_users returns users matching by name" do
    results = User.search_users("lazaro_nixon")
    assert_includes results, users(:lazaro_nixon)
    assert_includes results, users(:lazaro)
  end

  test "search_users returns user matching by handle" do
    results = User.search_users("1234")
    assert_includes results, users(:lazaro_nixon)
    assert_not_includes results, users(:lazaro)
  end

  test "search_users is case insensitive" do
    results = User.search_users("LAZARO_NIXON")
    assert_includes results, users(:lazaro_nixon)
  end

  test "search_users returns none with blank query" do
    assert_empty User.search_users("")
    assert_empty User.search_users(nil)
  end

  test "search_users returns none when no match" do
    assert_empty User.search_users("nonexistent_user_xyz")
  end

  test "rejects names that contain links" do
    [ "Win $500 https://scam.example", "www.promo-fit", "visit scam.com", "bit.ly/abc", "t.me/channel", "scam.pro", "scam.tech" ].each do |name|
      user = User.new(name: name, email: "spam@example.com", password: "Secret1*3*5*")

      assert_not user.valid?, "expected #{name.inspect} to be rejected"
      assert user.errors.of_kind?(:name, :contains_link)
    end
  end

  test "accepts ordinary names with dots and symbols" do
    [ "J.R.R. Tolkien", "Dr. Silva", "Ana.Paula", "Léo 2.0", "José D'Ávila" ].each do |name|
      user = User.new(name: name, email: "ok@example.com", password: "Secret1*3*5*")

      assert user.valid?, "expected #{name.inspect} to be accepted: #{user.errors.full_messages}"
    end
  end

  test "rejects adding a link when renaming" do
    user = users(:lazaro_nixon)

    assert_not user.update(name: "Free coins https://scam.example")
    assert user.errors.of_kind?(:name, :contains_link)
  end

  test "name_without_links drops link words and falls back to the handle" do
    user = users(:lazaro_nixon)

    user.name = "Win $500 https://scam.example now"
    assert_equal "Win $500 now", user.name_without_links

    user.name = "https://scam.example"
    assert_equal user.handle, user.name_without_links
  end
end
