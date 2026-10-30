require "test_helper"

class Sheets::GenerationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = sign_in_as(users(:lazaro_nixon))
  end

  test "saves the suggested sheets and points back to them on the list" do
    assert_difference -> { @user.sheets.count } => 2, -> { Workout.count } => 1, -> { Diet.count } => 1 do
      post sheets_generation_url, as: :json, params: { sheets: [
        { name: "Legs", sheet_type: "workout", workouts: [ { exercise: "Squat", series: 4, repetitions: "8" } ] },
        { name: "Bulk", sheet_type: "diet", diets: [ { meal: "Breakfast", protein_g: 30 } ] }
      ] }
    end

    assert_response :created
    assert_equal sheets_path(suggested: @user.sheets.where(suggested: true).order(:position).ids), response.parsed_body["location"]
  end

  test "ignores attributes the suggestion should not set" do
    post sheets_generation_url, as: :json, params: { sheets: [ { name: "Legs", sheet_type: "workout", user_id: users(:lazaro).id, workouts: [ { exercise: "Squat", series: 4, repetitions: "8", sheet_id: sheets(:two).id } ] } ] }

    sheet = @user.sheets.find_by!(name: "Legs")
    assert_equal [ "Squat" ], sheet.workouts.pluck(:exercise)
    assert_empty users(:lazaro).sheets
  end
end
