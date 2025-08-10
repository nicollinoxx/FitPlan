require "test_helper"

class DietTest < ActiveSupport::TestCase
  setup do
    @diet = diets(:diet_without_calories)
  end

  test "calculate_calories should compute correctly" do
    @diet.send(:calculate_calories)

    expected_calories = (10*4 + 20*4 + 5*9).round(2)
    assert_equal expected_calories, @diet.calories
  end


  test "percentage_of_calories should compute percentages correctly" do
    @diet.send(:calculate_calories)

    expected = {
      protein: (10*4 / @diet.calories * 100).round(2),
      carbohydrate: (20*4 / @diet.calories * 100).round(2),
      fat: (5*9 / @diet.calories * 100).round(2)
    }

    assert_equal expected, @diet.percentage_of_calories
  end
end
