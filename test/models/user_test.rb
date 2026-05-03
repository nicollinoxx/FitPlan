require "test_helper"

class UserTest < ActiveSupport::TestCase
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
