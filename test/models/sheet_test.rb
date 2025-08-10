require "test_helper"

class SheetTest < ActiveSupport::TestCase
  setup do
    @sheets = [sheets(:one), sheets(:two)]
  end

  test "should destroy workouts when changing sheet_type to diet" do
    @sheets.first.update!(sheet_type: :diet)

    assert_empty @sheets.first.workouts.reload
  end

  test "should destroy diets when changing sheet_type to workout" do
    @sheets.second.update!(sheet_type: :workout)

    assert_empty @sheets.second.diets.reload
  end
end
