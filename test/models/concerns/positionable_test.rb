require "test_helper"

class PositionableTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
  end

  test "places a new record last within its scope" do
    assert_equal 5, @user.sheets.create!(name: "New", sheet_type: "workout").position
    assert_equal 4, sheets(:one).workouts.create!(exercise: "New", series: 1, repetitions: 1).position
  end

  test "moving a record up pushes the ones in between down" do
    sheets(:empty_diet).update!(position: 2)

    assert_equal sheets(:one, :empty_diet, :two, :empty_workout), @user.sheets.positioned
  end

  test "moving a record down pulls the ones in between up" do
    sheets(:one).update!(position: 3)

    assert_equal sheets(:two, :empty_workout, :one, :empty_diet), @user.sheets.positioned
  end

  test "destroying a record closes the gap" do
    sheets(:two).destroy!

    assert_equal [ 1, 2, 3 ], @user.sheets.positioned.pluck(:position)
  end

  test "only records within the same scope are shifted" do
    workouts(:fixture_workout).update!(position: 1)

    assert_equal workouts(:fixture_workout, :one, :another), sheets(:one).workouts.positioned
    assert_equal 1, workouts(:two).reload.position
  end
end
