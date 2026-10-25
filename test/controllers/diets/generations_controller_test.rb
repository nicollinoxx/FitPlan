require "test_helper"

class Diets::GenerationsControllerTest < ActionDispatch::IntegrationTest
  test "adds the suggested diets to an existing sheet" do
    sign_in_as(users(:lazaro_nixon))

    post sheet_diets_generation_url(sheets(:two)), as: :json, params: { diets: [ { meal: "Snack", protein_g: 20 } ] }

    assert_response :created
    assert_equal sheet_diets_path(sheets(:two)), response.parsed_body["location"]
    assert_equal "Snack", sheets(:two).diets.positioned.last.meal
  end

  test "cannot add to someone else's sheet" do
    sign_in_as(users(:lazaro))

    assert_no_difference "Diet.count" do
      post sheet_diets_generation_url(sheets(:two)), as: :json, params: { diets: [ { meal: "Snack", protein_g: 20 } ] }
    end

    assert_response :not_found
  end
end
