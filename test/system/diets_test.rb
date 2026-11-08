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

    fill_in :diet_meal, with: @diet.meal
    fill_in :diet_protein_g, with: @diet.protein_g
    fill_in :diet_carbohydrate_g, with: @diet.carbohydrate_g
    fill_in :diet_fat_g, with: @diet.fat_g
    click_on t("save")

    assert_text t("notice.diet.create")
  end

  test "should update Diet" do
    visit sheet_diet_url(@sheet, @diet)
    click_on t("edit"), match: :first

    fill_in :diet_meal, with: @diet.meal
    fill_in :diet_protein_g, with: @diet.protein_g
    fill_in :diet_carbohydrate_g, with: @diet.carbohydrate_g
    fill_in :diet_fat_g, with: @diet.fat_g
    click_on t("save")

    assert_text t("notice.diet.update")
  end

  test "should destroy Diet" do
    visit sheet_diet_url(@sheet, @diet)
    click_on t("destroy"), match: :first
    confirm_dialog

    assert_text t("notice.diet.destroy")
  end
end
