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
    assert_select "input[name=handle][value='#{@recipient.handle}']"
  end

  test "should get new without recipient handle" do
    get new_shares_shared_sheet_url
    assert_response :success
    assert_select "form"
  end

  test "should create shared_sheets successfully" do
    sheet_ids = @user.sheets.limit(2).pluck(:id)

    assert_difference("SharedSheet.count", 2) do
      post shares_shared_sheets_url, params: { handle: @recipient.handle, sheet_ids: sheet_ids }
    end

    assert_redirected_to shares_shared_sheets_path
    follow_redirect!
    assert_match "Fichas compartilhadas com sucesso!", response.body
  end

  test "should render new on create failure" do
    post shares_shared_sheets_url, params: { handle: @recipient.handle, sheet_ids: [1] }
    assert_response :no_content
  end

  test "should accept shared_sheet and enqueue job" do
    @shared_sheet = shared_sheets(:one)
    sign_in_as(@shared_sheet.recipient)

    patch accept_shares_shared_sheet_path(@shared_sheet, format: :turbo_stream)

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
