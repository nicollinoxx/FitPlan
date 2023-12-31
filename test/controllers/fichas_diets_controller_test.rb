require "test_helper"

class FichasDietsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fichas_diets_index_url
    assert_response :success
  end

  test "should get shoe" do
    get fichas_diets_shoe_url
    assert_response :success
  end

  test "should get new" do
    get fichas_diets_new_url
    assert_response :success
  end

  test "should get edit" do
    get fichas_diets_edit_url
    assert_response :success
  end

  test "should get create" do
    get fichas_diets_create_url
    assert_response :success
  end

  test "should get update" do
    get fichas_diets_update_url
    assert_response :success
  end

  test "should get destroy" do
    get fichas_diets_destroy_url
    assert_response :success
  end
end
