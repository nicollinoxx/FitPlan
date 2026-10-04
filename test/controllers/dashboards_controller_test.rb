require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)
  end

  test "should get show" do
    get dashboard_url

    assert_response :success
    assert_select "h1", text: I18n.t("dashboards.show.title")
  end

  test "show names every card" do
    get dashboard_url

    assert_response :success
    I18n.t("dashboards.show.cards").except(:days).each_value do |title|
      assert_select "h2", text: title
    end
    assert_select ".translation_missing", false
  end

  test "show explains every card through the shared dialog" do
    get dashboard_url

    assert_response :success
    assert_select "[data-hint-target=?]", "dialog", count: 1
    I18n.t("dashboards.show.hints").each_value do |hint|
      assert_select "[data-hint-body-param=?]", hint
    end
  end

  test "show starts the weekly progress bar empty" do
    SheetCompletion.create!(sheet: sheets(:one), user: @user, completed_at: Time.current)

    get dashboard_url

    assert_response :success
    assert_select ".progress-bar[style=?]", "width: 0"
    assert_select ".progress-bar[data-progress-percentage-value]"
  end

  test "should get charts as turbo_stream" do
    get charts_dashboard_url(format: :turbo_stream)

    assert_response :success
    assert_select "turbo-stream[target=?]", "charts"
  end

  test "charts hand each series to the chart controller" do
    get charts_dashboard_url(format: :turbo_stream)

    assert_response :success
    assert_select "[data-controller=?]", "chart", count: 3
    assert_select "[data-chart-type-value=?]", "Line"
    assert_select "[data-chart-type-value=?]", "Column"
    assert_select "[data-chart-type-value=?]", "Bar"
  end

  test "charts name the series in the current locale" do
    sheet = sheets(:one)
    SheetCompletion.create!(sheet: sheet, user: @user, completed_at: Time.current)

    get charts_dashboard_url(format: :turbo_stream)

    assert_response :success
    assert_select "[data-chart-type-value=?]", "Line" do |elements|
      assert_includes elements.first["data-chart-data-value"], I18n.t("workout")
    end
  end

  test "charts honor the requested period" do
    get charts_dashboard_url(period: "year", format: :turbo_stream)

    assert_response :success
    assert_select "button", text: /#{Regexp.escape(I18n.t('dashboards.charts.filters.period.year'))}/
  end
end
