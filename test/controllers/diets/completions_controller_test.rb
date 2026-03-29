require "test_helper"

class Diets::CompletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @sheet = sheets(:two)
    @diet = diets(:one)
  end

  test "should create completion" do
    assert_difference("Completion.count") do
      post sheet_diet_completion_url(@sheet, @diet)
    end

    assert_redirected_to sheet_diets_url(@sheet)
  end

  test "should destroy completion" do
    @sheet.completions.create!(diet: @diet)

    assert_difference("Completion.count", -1) do
      delete sheet_diet_completion_url(@sheet, @diet)
    end

    assert_redirected_to sheet_diets_url(@sheet)
  end

  test "should create sheet_completion when all diets completed" do
    assert_difference("SheetCompletion.count") do
      @sheet.diets.each do |diet|
        post sheet_diet_completion_url(@sheet, diet)
      end
    end
  end
end
