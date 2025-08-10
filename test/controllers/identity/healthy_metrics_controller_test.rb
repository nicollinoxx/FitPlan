require "test_helper"

class Identity::HealthyMetricsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon))
    @healthy_metric = healthy_metrics(:one)
    @user = users(:lazaro_nixon)
  end

  test "should get new" do
    get new_identity_healthy_metric_url
    assert_response :success
  end

  test "should create healthy_metric" do
    @healthy_metric.destroy

    assert_difference("HealthyMetric.count", 1) do
      post identity_healthy_metric_url, params: { healthy_metric: { height: 180, weight: 75, birth_date: "1990-01-01", gender: "male" } }
    end

    assert_redirected_to identity_healthy_metric_path(HealthyMetric.last)
  end

  test "should show healthy_metric" do
    get identity_healthy_metric_url(@healthy_metric)
    assert_response :success
  end

  test "should get edit" do
    get edit_identity_healthy_metric_url(@healthy_metric)
    assert_response :success
  end

  test "should update healthy_metric" do
    patch identity_healthy_metric_url(@healthy_metric), params: { healthy_metric: { height: "1.23", weight: "65.2", birth_date: "19/02/1999", gender: "male" } }
    assert_redirected_to identity_healthy_metric_path(@healthy_metric)
  end

  test "should not create healthy_metric with invalid data" do
    @healthy_metric.destroy

    assert_no_difference("HealthyMetric.count") do
      post identity_healthy_metric_url, params: { healthy_metric: { height: nil } }
    end

    assert_response :unprocessable_entity
  end
end
