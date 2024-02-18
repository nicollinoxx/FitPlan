require "test_helper"

class TreinosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @treino = treinos(:one)
  end

  test "should get index" do
    get ficha_treinos_url(@treino.ficha_id)
    assert_response :success
  end

  test "should get new" do
    get new_ficha_treino_url(@treino.ficha_id)
    assert_response :success
  end

  test "should create treino" do
    assert_difference("Treino.count") do
      post ficha_treinos_url(@treino.ficha_id), params: { treino: { carga: @treino.carga, exercicio: @treino.exercicio, repeticoes: @treino.repeticoes, series: @treino.series } }
    end

    assert_redirected_to ficha_treino_url(@treino.ficha_id, Treino.last)
  end

  test "should show treino" do
    get ficha_treino_url(@treino.ficha_id, @treino)
    assert_response :success
  end

  test "should get edit" do
    get edit_ficha_treino_url(@treino.ficha_id, @treino)
    assert_response :success
  end

  test "should update treino" do
    patch ficha_treino_url(@treino.ficha_id, @treino), params: { treino: { carga: @treino.carga, exercicio: @treino.exercicio, repeticoes: @treino.repeticoes, series: @treino.series } }
    assert_redirected_to ficha_treino_url(@treino.ficha_id, @treino)
  end

  test "should destroy treino" do
    assert_difference("Treino.count", -1) do
      delete ficha_treino_url(@treino.ficha_id, @treino)
    end

    assert_redirected_to ficha_url(@treino.ficha_id)
  end
end
