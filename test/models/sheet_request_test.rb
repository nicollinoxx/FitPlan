require "test_helper"

class SheetRequestTest < ActiveSupport::TestCase
  setup do
    @sender = users(:lazaro_nixon)
    @recipient = users(:lazaro)
    @sheet = sheets(:one)
    @sheet_request = sheet_requests(:one)
  end

  teardown do
    Current.reset
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

  test "create_for_sheets does nothing when more than 5 sheet_ids are sent" do
    sheet_id = @sender.sheets.pick(:id)

    assert_not_nil sheet_id
    sheet_ids = Array.new(6, sheet_id)

    assert_no_difference("SheetRequest.count") do
      SheetRequest.create_for_sheets(sender: @sender, recipient: @recipient, sheet_ids: sheet_ids)
    end
  end

  test "create_for_sheets does nothing when sheet_ids is empty" do
    assert_no_difference("SheetRequest.count") do
      SheetRequest.create_for_sheets(sender: @sender, recipient: @recipient, sheet_ids: [])
    end
  end

  test "create_for_sheets creates pending requests for up to 5 valid sheet_ids" do
    sheet_ids = [sheets(:two).id, sheets(:empty_workout).id]

    assert_difference("SheetRequest.count", 2) do
      SheetRequest.create_for_sheets(sender: @sender, recipient: @recipient, sheet_ids: sheet_ids)
    end

    created_requests = SheetRequest.where(sender: @sender, recipient: @recipient, sheet_id: sheet_ids)
    assert_equal 2, created_requests.count
    assert_equal ["pending"], created_requests.distinct.pluck(:status)
  end

  test "create_for_sheets raises RecordNotFound when a sheet does not belong to sender" do
    outsider_sheet = @recipient.sheets.create!(name: "Recipient Sheet", sheet_type: "workout")

    assert_no_difference("SheetRequest.count") do
      assert_raises(ActiveRecord::RecordNotFound) do
        SheetRequest.create_for_sheets(sender: @sender, recipient: @recipient, sheet_ids: [outsider_sheet.id])
      end
    end
  end

  test "cannot accept request when current user is not recipient" do
    Current.session = sessions(:sender_session)

    error = assert_raises(ActiveRecord::RecordInvalid) do
      @sheet_request.accepted!
    end

    assert_includes error.record.errors[:base], I18n.t("errors.sheet_request.not_recipient")
  end

  test "can accept request when current user is recipient" do
    Current.session = sessions(:recipient_session)

    @sheet_request.accepted!
    assert @sheet_request.accepted?
  end
end
