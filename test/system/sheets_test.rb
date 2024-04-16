require "application_system_test_case"

class SheetsTest < ApplicationSystemTestCase
  setup do
    @sheet = sheets(:one)
  end

  test "visiting the index" do
    visit sheets_url
    assert_selector "h1", text: "Sheets"
  end

  test "should create sheet" do
    visit sheets_url
    click_on "New sheet"

    fill_in "Description", with: @sheet.description
    fill_in "Name", with: @sheet.name
    fill_in "Type", with: @sheet.type
    click_on "Create Sheet"

    assert_text "Sheet was successfully created"
    click_on "Back"
  end

  test "should update Sheet" do
    visit sheet_url(@sheet)
    click_on "Edit this sheet", match: :first

    fill_in "Description", with: @sheet.description
    fill_in "Name", with: @sheet.name
    fill_in "Type", with: @sheet.type
    click_on "Update Sheet"

    assert_text "Sheet was successfully updated"
    click_on "Back"
  end

  test "should destroy Sheet" do
    visit sheet_url(@sheet)
    click_on "Destroy this sheet", match: :first

    assert_text "Sheet was successfully destroyed"
  end
end
