require "application_system_test_case"

class SheetsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:lazaro_nixon))
    @sheet = sheets(:one)
  end

  test "visiting the index" do
    visit sheets_url
    assert_selector "h1", text: t("sheets.index.title")
  end

  test "should create sheet" do
    visit sheets_url
    click_on t("new")

    fill_in :sheet_name, with: @sheet.name
    fill_in :sheet_description, with: @sheet.description
    choose "sheet_sheet_type_#{@sheet.sheet_type}"
    click_on t("save")

    assert_text t("notice.sheet.create")
  end

  test "should update Sheet" do
    visit sheet_url(@sheet)
    click_on t("edit"), match: :first

    fill_in :sheet_name, with: @sheet.name
    fill_in :sheet_description, with: @sheet.description
    click_on t("save")

    assert_text t("notice.sheet.update")
  end

  test "should destroy Sheet" do
    visit sheet_url(@sheet)
    click_on t("destroy"), match: :first
    confirm_dialog

    assert_text t("notice.sheet.destroy")
  end
end
