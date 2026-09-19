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

  test "sheet completion ignores client dates and timezone" do
    travel_to Time.zone.local(2026, 9, 30, 23, 30) do
      post sheet_completion_url(@workout_sheet), params: {
        completed_at: 1.month.from_now, current_date: 1.month.from_now.to_date, timezone: "Pacific/Auckland",
        sheet_completion: { completed_at: 1.month.ago, created_at: 1.month.ago }, ranking_score: 100
      }

      assert_response :success
      assert_equal Time.current, @workout_sheet.sheet_completions.order(:id).last.completed_at
    end
  end
end
