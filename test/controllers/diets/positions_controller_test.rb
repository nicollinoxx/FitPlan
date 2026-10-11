require "test_helper"

class Diets::PositionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
  end

  test "moves the diet to the given position" do
    patch sheet_diet_position_url(sheets(:two), diets(:fixture_diet)), params: { diet: { position: 1 } }, as: :json

    assert_response :no_content
    assert_equal 1, diets(:fixture_diet).reload.position
    assert_equal 2, diets(:one).reload.position
  end
end
