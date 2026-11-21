require "test_helper"

class Diets::GenerationsControllerTest < ActionDispatch::IntegrationTest
  test "adds the suggested diets to an existing sheet" do
    sign_in_as(users(:lazaro_nixon))

    post sheet_diets_generation_url(sheets(:two)), as: :json, params: { token: recommendations(:diets).token, diets: [ { meal: "Snack", protein_g: 20 } ] }

    assert_response :created
    assert_equal sheet_diets_path(sheets(:two)), response.parsed_body["location"]
    assert_equal "Snack", sheets(:two).diets.positioned.last.meal
  end

  test "saving twice with the same token adds the diets only once" do
    sign_in_as(users(:lazaro_nixon))
    params = { token: recommendations(:diets).token, diets: [ { meal: "Snack", protein_g: 20 } ] }

    post sheet_diets_generation_url(sheets(:two)), as: :json, params: params
    assert_response :created

    assert_no_difference "Diet.count" do
      post sheet_diets_generation_url(sheets(:two)), as: :json, params: params
    end

    assert_response :created
  end

  test "cannot add to someone else's sheet" do
    sign_in_as(users(:lazaro))

    assert_no_difference "Diet.count" do
      post sheet_diets_generation_url(sheets(:two)), as: :json, params: { token: recommendations(:diets).token, diets: [ { meal: "Snack", protein_g: 20 } ] }
    end

    assert_response :not_found
  end

  test "applies the suggested changes to the existing diets" do
    sign_in_as(users(:lazaro_nixon))
    item = diets(:one)

    patch sheet_diets_generation_url(sheets(:two)), as: :json, params: { diets: [ { id: item.id, meal: "Brunch" } ] }

    assert_response :success
    assert_equal "Brunch", item.reload.meal.to_s
  end
end
