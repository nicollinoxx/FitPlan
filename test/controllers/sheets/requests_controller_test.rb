require "test_helper"

class Sheets::RequestsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)

    @recipient = users(:lazaro)
    @sheet_request = sheet_requests(:one)
  end

  test "should get index" do
    get requests_url
    assert_response :success
  end

  test "should get new with recipient handle" do
    get new_request_url(handle: @recipient.handle)
    assert_response :success
    assert_select "form"
  end

  test "should get new without recipient handle" do
    get new_request_url
    assert_response :success
    assert_select "form"
  end

  test "should create sheet_requests successfully" do
    sheet_ids = @user.sheets.limit(2).pluck(:id)

    assert_difference("SheetRequest.count", 2) do
      post requests_url, params: { sheet_ids: sheet_ids, handle: @recipient.handle }
    end

    sheet_ids.each do |sheet_id|
      sheet_request = SheetRequest.find_by(recipient: @recipient, sheet_id: sheet_id)
      assert_equal "pending", sheet_request.status, "O status do SheetRequest deve ser 'pending'"
    end

    assert_redirected_to requests_url(filter: "sent")
    follow_redirect!
    assert_match I18n.t("notice.sheet_request.create"), response.body
  end

  test "should accept sheet_request and enqueue job" do
    sign_in_as(@sheet_request.recipient)

    assert_enqueued_with(job: CopySheetJob, args: [@sheet_request]) do
      patch accept_request_path(@sheet_request, format: :turbo_stream)
    end

    @sheet_request.reload
    assert_equal "accepted", @sheet_request.status
    assert_response :success
    assert_match /turbo-stream/, @response.body
  end

  test "should destroy sheet_request" do
    assert_difference("SheetRequest.count", -1) do
      delete request_url(@sheet_request, format: :turbo_stream)
    end

    assert_response :success
    assert_match "turbo-stream", response.media_type
    assert_match "request_#{@sheet_request.id}", response.body
  end
end
