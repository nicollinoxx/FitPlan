require "application_system_test_case"

class DietsTest < ApplicationSystemTestCase
  setup do
    sign_in_as(users(:lazaro_nixon))
    @diet = diets(:one)
    @sheet = sheets(:two)
  end

  test "visiting the index" do
    visit sheet_diets_url(@sheet)
    assert_selector "h1", text: @sheet.name
  end

  test "should create diet" do
    visit new_sheet_diet_url(@sheet)

    fill_in "Carbohydrates g", with: @diet.carbohydrate_g
    fill_in "Fat g", with: @diet.fat_g
    fill_in "Proteins g", with: @diet.protein_g
    fill_in "Meal", with: @diet.meal
    click_on "Save"

    assert_text "Diet was successfully created"
  end

  test "should update Diet" do
    visit sheet_diet_url(@sheet, @diet)
    click_on "Edit", match: :first

    fill_in "Carbohydrates g", with: @diet.carbohydrate_g
    fill_in "Fat g", with: @diet.fat_g
    fill_in "Proteins g", with: @diet.protein_g
    fill_in "Meal", with: @diet.meal
    click_on "Save"

    assert_text "Diet was successfully updated"
  end

  test "should destroy Diet" do
    visit sheet_diet_url(@sheet, @diet)
    click_on "Destroy", match: :first

    assert_selector "dialog[open]", visible: true

    within "dialog[open]" do
      click_on "Confirm"
    end

    assert_text "Diet was successfully destroyed"
  end
end
