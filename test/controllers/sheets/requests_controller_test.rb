require "test_helper"

class Sheets::RequestsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user    = users(:lazaro_nixon)
    @sheet_request = sheet_requests(:one)
    sign_in_as(@user)
  end

  test "should accept request and enqueue job" do
    sign_in_as(@sheet_request.recipient)

    assert_enqueued_with(job: CopySheetJob, args: [ @sheet_request ]) do
      patch sheets_request_path(@sheet_request, format: :turbo_stream)
    end

    assert @sheet_request.reload.accepted?
    assert_response :success
  end

  test "should destroy request" do
    assert_difference("SheetRequest.count", -1) do
      delete sheets_request_path(@sheet_request, format: :turbo_stream)
    end

    assert_response :success
  end
end
