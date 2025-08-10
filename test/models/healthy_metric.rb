require "test_helper"

class HealthyMetricTest < ActiveSupport::TestCase
  test "calculate_healthy_metrics calculates IMC and TMB correctly" do
    user_detail = UserDetail.new(weight: 70, height: 1.75, birth_date: 20.years.ago.to_date, gender: "male")

    user_detail.send(:calculate_healthy_metrics)

    expected_imc = (70 / (1.75**2)).round(2)
    assert_equal expected_imc, user_detail.imc

    age = ((Time.zone.now - user_detail.birth_date.to_time) / 1.year).floor
    expected_tmb = (10 * 70 + 6.25 * 175 - 5 * age + 5).round(2)
    assert_equal expected_tmb, user_detail.tmb
  end
end
