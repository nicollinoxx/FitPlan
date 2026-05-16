require "test_helper"

class UserTest < ActiveSupport::TestCase
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
end
