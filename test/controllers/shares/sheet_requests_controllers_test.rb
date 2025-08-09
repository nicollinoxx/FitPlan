require "test_helper"

class Shares::SheetRequestsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)

    @recipient = users(:lazaro)
    @sheet_request = sheet_requests(:one)
  end

  test "should get index" do
    get shares_sheet_requests_url
    assert_response :success
  end

  test "should get new with recipient handle" do
    get new_shares_sheet_request_url(handle: @recipient.handle)
    assert_response :success
    assert_select "form"
  end

  test "should get new without recipient handle" do
    get new_shares_sheet_request_url
    assert_response :success
    assert_select "form"
  end

  test "should create sheet_requests successfully" do
    sheet_ids = @user.sheets.limit(2).pluck(:id)

    assert_difference("SheetRequest.count", 2) do
      post shares_sheet_requests_url, params: { sheet_ids: sheet_ids, handle: @recipient.handle }
    end

    follow_redirect!
    assert_match "Fichas compartilhadas com sucesso!", response.body

    sheet_ids.each do |sheet_id|
      sheet_request = SheetRequest.find_by(recipient: @recipient, sheet_id: sheet_id)
      assert_equal "pending", sheet_request.status, "O status do SheetRequest deve ser 'pending'"
    end
  end

  test "should accept sheet_request and enqueue job" do
    @sheet_request = sheet_requests(:one)
    sign_in_as(@sheet_request.recipient)

    assert_enqueued_with(job: CopySheetJob, args: [@sheet_request.recipient, @sheet_request.sheet]) do
      patch accept_shares_sheet_request_path(@sheet_request, format: :turbo_stream)
    end

    @sheet_request.reload
    assert_equal "accepted", @sheet_request.status
    assert_response :success
    assert_match /turbo-stream/, @response.body
  end

  test "should destroy sheet_request" do
    sheet_request = @user.received_sheet_requests.first

    assert_difference("SheetRequest.count", -1) do
      delete shares_sheet_request_url(sheet_request, format: :turbo_stream)
    end

    assert_response :success
    assert_match "turbo-stream", response.media_type
    assert_match "sheet_request_#{sheet_request.id}", response.body
  end
end
