require "test_helper"

module Marketplace
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:lazaro_nixon)
      sign_in_as(@user)
    end

    test "should get index" do
      get marketplace_products_url

      assert_response :success
    end
  end
end
