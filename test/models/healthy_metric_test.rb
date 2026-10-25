require "test_helper"

class HealthyMetricTest < ActiveSupport::TestCase
  test "recommendation profile describes the person without anything that identifies them" do
    metric = HealthyMetric.new(weight: 70, height: 1.75, birth_date: 20.years.ago.to_date - 1.day, gender: "male", imc: 22.86, tmb: 1700)

    assert_equal({ gender: "male", age: 20, weight_kg: 70.0, height_m: 1.75, bmi: 22.86, bmr_kcal: 1700.0 }, metric.recommendation_profile)
  end

  test "recommendation profile leaves out what is unknown" do
    assert_equal({ weight_kg: 70.0 }, HealthyMetric.new(weight: 70).recommendation_profile)
  end
end
