require "test_helper"

class SessionHandoffTest < ActiveSupport::TestCase
  test "a completed code is claimed once" do
    with_memory_cache do
      code = SessionHandoff.issue
      SessionHandoff.complete(code, users(:lazaro_nixon))

      assert_equal users(:lazaro_nixon), SessionHandoff.claim(code)
      assert_nil SessionHandoff.claim(code)
    end
  end

  test "a code nobody completed claims nothing" do
    with_memory_cache do
      assert_nil SessionHandoff.claim(SessionHandoff.issue)
      assert_nil SessionHandoff.claim(nil)
    end
  end

  test "codes expire" do
    with_memory_cache do
      code = SessionHandoff.issue
      SessionHandoff.complete(code, users(:lazaro_nixon))

      travel SessionHandoff::EXPIRES_IN + 1.second do
        assert_nil SessionHandoff.claim(code)
      end
    end
  end
end
