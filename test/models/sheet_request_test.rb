require "test_helper"

class SheetRequestTest < ActiveSupport::TestCase
  setup do
    @sender = users(:lazaro_nixon)
    @recipient = users(:lazaro)
    @sheet = sheets(:one)
    @sheet_request = sheet_requests(:one)
  end

  test "sender? should return true when user is sender" do
    assert @sheet_request.sender?(@sender)
  end

  test "sender? should return false when user is not sender" do
    refute @sheet_request.sender?(@recipient)
  end

  test "receiver? should return true when user is recipient" do
    assert @sheet_request.receiver?(@recipient)
  end

  test "receiver? should return false when user is not recipient" do
    refute @sheet_request.receiver?(@sender)
  end
end
