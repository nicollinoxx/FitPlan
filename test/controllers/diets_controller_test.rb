require "test_helper"

class DietsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @diet  = diets(:one)
    @sheet = sheets(:two)
  end

  test "should get index" do
    get sheet_diets_url(@sheet)
    assert_response :success
  end

  test "should get new" do
    get new_sheet_diet_url(@sheet)
    assert_response :success
  end

  test "should create diet" do
    assert_difference("Diet.count") do
      post sheet_diets_url(@sheet), params: { diet: { calories: @diet.calories, carbohydrate_g: @diet.carbohydrate_g, description: "my description", fat_g: @diet.fat_g, protein_g: @diet.protein_g, meal: @diet.meal } }
    end

    assert_redirected_to sheet_diet_url(@sheet, Diet.last)
  end

  test "should show diet" do
    get sheet_diet_url(@sheet, @diet)
    assert_response :success
  end

  test "should get edit" do
    get edit_sheet_diet_url(@sheet, @diet)
    assert_response :success
  end

  test "should update diet" do
    patch sheet_diet_url(@sheet, @diet), params: { diet: { calories: @diet.calories, carbohydrate_g: @diet.carbohydrate_g, description: "my description", fat_g: @diet.fat_g, protein_g: @diet.protein_g, meal: @diet.meal } }
    assert_redirected_to sheet_diet_url(@sheet, @diet)
  end

  test "should destroy diet" do
    assert_difference("Diet.count", -1) do
      delete sheet_diet_url(@sheet, @diet)
    end

    assert_redirected_to sheet_diets_url(@sheet)
  end
end
