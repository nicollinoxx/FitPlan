require "test_helper"

module Sheets
  class CopyableTest < ActiveSupport::TestCase
    setup do
      @recipient = users(:lazaro_nixon) #
    end

    test "copies a workout sheet with workouts and videos" do
      sheet = sheets(:empty_workout)

      workout = sheet.workouts.create!(exercise: "Workout A", repetitions: 10, series: 3)
      workout.video.attach(
        io: File.open(Rails.root.join("test/fixtures/files/sample_video.mp4")),
        filename: "sample_video.mp4",
        content_type: "video/mp4"
      )

      assert_difference -> { @recipient.sheets.count }, 1 do
        sheet.copy_to(@recipient)
      end

      copied_sheet = @recipient.sheets.order(created_at: :desc).first
      assert copied_sheet.workout?

      assert_equal 1, copied_sheet.workouts.count
      assert copied_sheet.workouts.first.video.attached?
    end

    test "copies a diet sheet with diets and rich text descriptions" do
      sheet = sheets(:two)

      diet = diets(:diet_without_calories)
      diet.update!(sheet: sheet, description: "<p>Rich description for testing</p>")

      assert_difference -> { @recipient.sheets.count }, 1 do
        sheet.copy_to(@recipient)
      end

      copied_sheet = @recipient.sheets.order(created_at: :desc).first
      assert copied_sheet.diet?
      assert_equal sheet.diets.count, copied_sheet.diets.count

      copied_diet = copied_sheet.diets.first
      assert_includes copied_diet.description.to_s, "Rich description for testing"
    end

    test "does not copy workout sheet when there are no workouts" do
      sheet = sheets(:empty_workout)

      assert_no_difference -> { @recipient.sheets.count } do
        sheet.copy_to(@recipient)
      end
    end

    test "does not copy diet sheet when there are no diets" do
      sheet = sheets(:empty_diet)

      assert_no_difference -> { @recipient.sheets.count } do
        sheet.copy_to(@recipient)
      end
    end
  end
end
