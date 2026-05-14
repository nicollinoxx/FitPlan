require "test_helper"

class SheetShareTest < ActiveSupport::TestCase
  setup do
    @sender    = users(:lazaro_nixon)
    @recipient = users(:lazaro)
  end

  test "create_with_requests creates a share and one request per valid sheet" do
    sheet_ids = [ sheets(:one).id, sheets(:two).id ]

    assert_difference("SheetShare.count", 1) do
      assert_difference("SheetRequest.count", sheet_ids.size) do
        SheetShare.create_with_requests(sender: @sender, recipient: @recipient, sheet_ids: sheet_ids)
      end
    end
  end

  test "create_with_requests returns nil when no valid sheets" do
    sheet_ids = [ sheets(:empty_workout).id ]
    assert_nil SheetShare.create_with_requests(sender: @sender, recipient: @recipient, sheet_ids: sheet_ids)
  end

  test "create_with_requests sets all requests as pending" do
    share = SheetShare.create_with_requests(sender: @sender, recipient: @recipient, sheet_ids: [ sheets(:one).id ])
    assert share.sheet_requests.all?(&:pending?)
  end
end
