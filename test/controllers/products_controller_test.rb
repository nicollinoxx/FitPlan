require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)
  end

  test "should get index" do
    get products_url

    assert_response :success
  end

  test "should get new" do
    get new_product_url

    assert_response :success
  end

  test "should create product with importable sheets" do
    assert_difference("Product.count", 1) do
      post products_url, params: {
        product: {
          title: "Pacote Pro",
          description: "Treino e dieta",
          status: "published",
          sheet_ids: [ sheets(:importable_workout).id ]
        }
      }
    end

    assert_redirected_to product_url(Product.last)
    assert_equal 1, Product.last.product_items.count
  end
end
