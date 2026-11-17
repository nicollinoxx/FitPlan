require "test_helper"

class HealthyMetricTest < ActiveSupport::TestCase
  test "recommendation profile describes the person without anything that identifies them" do
    metric = HealthyMetric.new(weight: 70, height: 1.75, birth_date: 20.years.ago.to_date - 1.day, gender: "male", imc: 22.86, tmb: 1700)

    assert_equal({ gender: "male", age: 20, weight_kg: 70.0, height_m: 1.75, bmi: 22.86, bmr_kcal: 1700.0 }, metric.recommendation_profile)
  end

  test "recommendation profile leaves out what is unknown" do
    assert_equal({ weight_kg: 70.0 }, HealthyMetric.new(weight: 70).recommendation_profile)
  end

  test "saves without any body metric and calculates nothing" do
    metric = users(:lazaro_nixon).build_healthy_metric
    metric.save!

    assert_nil metric.imc
    assert_nil metric.tmb
    assert_empty metric.recommendation_profile
  end

  test "calculates the BMI from height and weight alone, and the BMR only with age and gender too" do
    metric = HealthyMetric.new(user: users(:lazaro_nixon), weight: 70, height: 1.75)
    metric.save!

    assert_equal 22.86, metric.imc.to_f
    assert_nil metric.tmb

    metric.update!(birth_date: 20.years.ago.to_date - 1.day, gender: "male")
    assert_equal 1698.75, metric.tmb.to_f
  end

  test "clears the calculated values when a metric is removed" do
    metric = HealthyMetric.create!(user: users(:lazaro_nixon), weight: 70, height: 1.75, birth_date: 20.years.ago.to_date - 1.day, gender: "male")
    metric.update!(height: nil)

    assert_nil metric.imc
    assert_nil metric.tmb
  end
end
