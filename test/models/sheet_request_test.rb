require "test_helper"

class SheetRequestTest < ActiveSupport::TestCase
  setup do
    @sender    = users(:lazaro_nixon)
    @recipient = users(:lazaro)
    @request   = sheet_requests(:one)
  end

  teardown { Current.reset }

  test "sender? returns true for sender" do
    assert @request.sender?(@sender)
  end

  test "sender? returns false for recipient" do
    refute @request.sender?(@recipient)
  end

  test "receiver? returns true for recipient" do
    assert @request.receiver?(@recipient)
  end

  test "receiver? returns false for sender" do
    refute @request.receiver?(@sender)
  end

  test "cannot accept when current user is not recipient" do
    Current.session = sessions(:sender_session)

    error = assert_raises(ActiveRecord::RecordInvalid) { @request.accepted! }
    assert_includes error.record.errors[:base], I18n.t("errors.sheet_request.not_recipient")
  end

  test "can accept when current user is recipient" do
    Current.session = sessions(:recipient_session)

    @request.accepted!
    assert @request.accepted?
  end
end
