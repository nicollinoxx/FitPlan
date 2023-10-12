require "application_system_test_case"

class FichasTest < ApplicationSystemTestCase
  setup do
    @ficha = fichas(:one)
  end

  test "visiting the index" do
    visit fichas_url
    assert_selector "h1", text: "Fichas"
  end

  test "should create ficha" do
    visit fichas_url
    click_on "New ficha"

    fill_in "Nome", with: @ficha.nome
    click_on "Create Ficha"

    assert_text "Ficha was successfully created"
    click_on "Back"
  end

  test "should update Ficha" do
    visit ficha_url(@ficha)
    click_on "Edit this ficha", match: :first

    fill_in "Nome", with: @ficha.nome
    click_on "Update Ficha"

    assert_text "Ficha was successfully updated"
    click_on "Back"
  end

  test "should destroy Ficha" do
    visit ficha_url(@ficha)
    click_on "Destroy this ficha", match: :first

    assert_text "Ficha was successfully destroyed"
  end
end
