require "test_helper"

class TreinosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @treino = treinos(:one)
  end

  test "should get index" do
    get treinos_url
    assert_response :success
  end

  test "should get new" do
    get new_treino_url
    assert_response :success
  end

  test "should create treino" do
    assert_difference("Treino.count") do
      post treinos_url, params: { treino: { carga: @treino.carga, exercicio: @treino.exercicio, repeticoes: @treino.repeticoes, series: @treino.series } }
    end

    assert_redirected_to treino_url(Treino.last)
  end

  test "should show treino" do
    get treino_url(@treino)
    assert_response :success
  end

  test "should get edit" do
    get edit_treino_url(@treino)
    assert_response :success
  end

  test "should update treino" do
    patch treino_url(@treino), params: { treino: { carga: @treino.carga, exercicio: @treino.exercicio, repeticoes: @treino.repeticoes, series: @treino.series } }
    assert_redirected_to treino_url(@treino)
  end

  test "should destroy treino" do
    assert_difference("Treino.count", -1) do
      delete treino_url(@treino)
    end

    assert_redirected_to treinos_url
  end
end
