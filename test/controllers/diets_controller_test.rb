require "test_helper"

class DietsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @diet = diets(:one)
  end

  test "should get index" do
    get ficha_diets_url(@diet.ficha_id)
    assert_response :success
  end

  test "should get new" do
    get new_ficha_diet_url(@diet.ficha_id)
    assert_response :success
  end

  test "should create diet" do
    assert_difference("Diet.count") do
      post ficha_diets_url(@diet.ficha_id), params: { diet: { calorias: @diet.calorias, carboidratos_g: @diet.carboidratos_g, descricao: @diet.descricao, gordura_g: @diet.gordura_g, proteina_g: @diet.proteina_g, refeicao: @diet.refeicao } }
    end

    assert_redirected_to ficha_diet_url(@diet.ficha_id, Diet.last)
  end

  test "should show diet" do
    get ficha_diet_url(@diet.ficha_id, @diet)
    assert_response :success
  end

  test "should get edit" do
    get edit_ficha_diet_url(@diet.ficha_id, @diet)
    assert_response :success
  end

  test "should update diet" do
    patch ficha_diet_url(@diet.ficha_id, @diet), params: { diet: { calorias: @diet.calorias, carboidratos_g: @diet.carboidratos_g, descricao: @diet.descricao, gordura_g: @diet.gordura_g, proteina_g: @diet.proteina_g, refeicao: @diet.refeicao } }
    assert_redirected_to ficha_diet_url(@diet.ficha_id, @diet)
  end

  test "should destroy diet" do
    assert_difference("Diet.count", -1) do
      delete ficha_diet_url(@diet.ficha_id, @diet)
    end

    assert_redirected_to ficha_url(@diet.ficha_id)
  end
end
