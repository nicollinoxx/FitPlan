require "test_helper"

class Sheets::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
  end

  test "moves the sheet to the given position" do
    patch sheet_position_url(sheets(:empty_diet)), params: { sheet: { position: 1 } }, as: :json

    assert_response :no_content
    assert_equal 1, sheets(:empty_diet).reload.position
    assert_equal 2, sheets(:one).reload.position
  end
end
