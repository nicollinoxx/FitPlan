require "test_helper"

class Sheets::CompletionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @workout_sheet = sheets(:one)
    @diet_sheet    = sheets(:two)
  end

  test "should mark workout sheet as completed" do
    assert_difference("SheetCompletion.count", 1) do
      post sheet_completion_url(@workout_sheet)
    end
  end

  test "should mark diet sheet as completed and create missing diet completions" do
    assert_difference -> { Completion.count }, @diet_sheet.diets.count do
      assert_difference "SheetCompletion.count", 1 do
        post sheet_completion_url(@diet_sheet)
      end
    end
  end

  test "should destroy latest sheet_completion and cascade its completions" do
    post sheet_completion_url(@diet_sheet)
    cascade_count = @diet_sheet.completions.where.not(sheet_completion_id: nil).count

    assert_difference "SheetCompletion.count", -1 do
      assert_difference "Completion.count", -cascade_count do
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
