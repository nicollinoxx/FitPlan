require "test_helper"

class Sheets::SharesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user      = users(:lazaro_nixon)
    @recipient = users(:lazaro)
    @share     = sheet_shares(:one)
    sign_in_as(@user)
  end

  test "should get index of received shares" do
    get sheets_shares_url

    assert_response :success
  end

  test "should get index of sent shares" do
    get sheets_shares_url(filter: "sent")

    assert_response :success
  end

  test "should show a share the user sent" do
    get sheets_share_url(@share)

    assert_response :success
  end

  test "should show a share the user received" do
    get sheets_share_url(sheet_shares(:two))

    assert_response :success
  end

  test "should redirect to shares when the share belongs to others" do
    share = SheetShare.create!(sender: @recipient, recipient: outsider)

    get sheets_share_url(share, filter: "sent")

    assert_redirected_to sheets_shares_url(filter: "sent")
  end

  test "should get new" do
    get new_sheets_share_url

    assert_response :success
  end

  test "should create share with a request per sheet" do
    assert_difference -> { SheetShare.count } => 1, -> { SheetRequest.count } => 2 do
      post sheets_shares_url, params: { handle: @recipient.handle, sheet_ids: [ sheets(:one).id, sheets(:two).id ] }
    end

    assert_redirected_to sheets_shares_url(filter: "sent", format: :html)
    assert_equal I18n.t("notice.sheet_request.create"), flash[:notice]
  end

  test "should not share sheets without content" do
    assert_no_difference "SheetShare.count" do
      post sheets_shares_url, params: { handle: @recipient.handle, sheet_ids: [ sheets(:empty_workout).id ] }
    end
  end

  test "should not share with someone who is not a friend" do
    assert_no_difference "SheetShare.count" do
      post sheets_shares_url, params: { handle: outsider.handle, sheet_ids: [ sheets(:one).id ] }
    end

    assert_response :not_found
  end

  test "should destroy share" do
    assert_difference("SheetShare.count", -1) do
      delete sheets_share_url(@share)
    end

    assert_redirected_to sheets_shares_url(format: :html)
    assert_equal I18n.t("notice.sheet_share.destroy"), flash[:notice]
  end

  test "should not destroy a share that belongs to others" do
    share = SheetShare.create!(sender: @recipient, recipient: outsider)

    assert_no_difference "SheetShare.count" do
      delete sheets_share_url(share)
    end

    assert_response :not_found
  end

  private
    def outsider
      @outsider ||= User.create!(name: "Outsider", email: "outsider@example.com", password: "Secret1*3*5*")
    end
end
