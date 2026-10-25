require "test_helper"

class OpenRouter::UsagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:lazaro_nixon)).connect_open_router!("sk-or-test")
  end

  test "shows how many free requests are left today" do
    stub_singleton(OpenRouter::Client, :key, ->(_) { { "free_model_daily_requests" => { "used" => 3, "limit" => 50, "remaining" => 47 } } }) do
      get open_router_usage_url
    end

    assert_select "turbo-frame#open_router_usage", text: /47.*50/
  end

  test "shows nothing when OpenRouter does not report the free requests" do
    stub_singleton(OpenRouter::Client, :key, ->(_) { nil }) do
      get open_router_usage_url
    end

    assert_select "turbo-frame#open_router_usage", text: ""
  end
end
