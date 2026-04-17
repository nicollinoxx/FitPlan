require "test_helper"

class Sheets::CompletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @workout_sheet = sheets(:one)
    @diet_sheet = sheets(:two)
  end

  test "should mark workout sheet as completed" do
    assert_difference "SheetCompletion.count", 1 do
      post sheet_completion_url(@workout_sheet)
    end
  end

  test "should mark diet sheet as completed" do
    assert_no_difference "Completion.count" do
      assert_difference "SheetCompletion.count", 1 do
        post sheet_completion_url(@diet_sheet)
      end
    end
  end

  test "should destroy the latest sheet completion" do
    @diet_sheet.completions.create!(diet: diets(:one))
    post sheet_completion_url(@diet_sheet)

    assert_difference "SheetCompletion.count", -1 do
      assert_difference "Completion.count", -1 do
        delete sheet_completion_url(@diet_sheet)
      end
    end
  end

  test "destroy is a no-op when sheet has no sheet_completion today" do
    assert_no_difference "SheetCompletion.count" do
      delete sheet_completion_url(@workout_sheet)
    end
  end
end
