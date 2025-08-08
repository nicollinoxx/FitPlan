require "test_helper"

class Shares::SharedSheetsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)

    @recipient = users(:lazaro)
    @shared_sheet = shared_sheets(:one)
  end

  test "should get index" do
    get shares_shared_sheets_url
    assert_response :success
  end

  test "should get new with recipient handle" do
    get new_shares_shared_sheet_url(handle: @recipient.handle)
    assert_response :success
    assert_select "form"
  end

  test "should get new without recipient handle" do
    get new_shares_shared_sheet_url
    assert_response :success
    assert_select "form"
  end

  test "should create shared_sheets successfully" do
    sheet_ids = @user.sheets.limit(2).pluck(:id)

    assert_difference("SharedSheet.count", 2) do
      post shares_shared_sheets_url, params: { sheet_ids: sheet_ids, handle: @recipient.handle }
    end

    follow_redirect!
    assert_match "Fichas compartilhadas com sucesso!", response.body

    sheet_ids.each do |sheet_id|
      shared_sheet = SharedSheet.find_by(recipient: @recipient, sheet_id: sheet_id)
      assert_equal "pending", shared_sheet.status, "O status do SharedSheet deve ser 'pending'"
    end
  end

  test "should accept shared_sheet and enqueue job" do
    @shared_sheet = shared_sheets(:one)
    sign_in_as(@shared_sheet.recipient)

    assert_enqueued_with(job: CopySheetJob, args: [@shared_sheet.recipient, @shared_sheet.sheet]) do
      patch accept_shares_shared_sheet_path(@shared_sheet, format: :turbo_stream)
    end

    @shared_sheet.reload
    assert_equal "accepted", @shared_sheet.status
    assert_response :success
    assert_match /turbo-stream/, @response.body
  end

  test "should destroy shared_sheet" do
    shared_sheet = @user.received_shared_sheets.first
    assert_difference("SharedSheet.count", -1) do
      delete shares_shared_sheet_url(shared_sheet, format: :turbo_stream)
    end

    assert_response :success
    assert_match "turbo-stream", response.media_type
    assert_match "shared_sheet_#{shared_sheet.id}", response.body
  end
end
