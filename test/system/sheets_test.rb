require "application_system_test_case"

class SheetsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:lazaro_nixon))
    @sheet = sheets(:one)
  end

  test "visiting the index" do
    visit sheets_url
    assert_selector "h1", text: "Sheets"
  end

  test "should create sheet" do
    visit sheets_url
    click_on "+ New"

    fill_in "Description", with: @sheet.description
    fill_in "Name", with: @sheet.name
    choose @sheet.sheet_type.capitalize

    click_on "Save"

    assert_text "Sheet was successfully created"
  end

  test "should update Sheet" do
    visit sheet_url(@sheet)
    click_on "Edit", match: :first

    fill_in "Description", with: @sheet.description
    fill_in "Name", with: @sheet.name
    choose @sheet.sheet_type.capitalize

    click_on "Save"

    assert_text "Sheet was successfully updated"
  end

  test "should destroy Sheet" do
    visit sheet_url(@sheet)
    click_on "Destroy", match: :first

    assert_selector "dialog[open]", visible: true

    within "dialog[open]" do
      click_on "Confirm"
    end

    assert_text "Sheet was successfully destroyed"
  end
end
