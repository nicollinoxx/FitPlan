require "test_helper"

class Sheets::ImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)

    product = @user.products.create!(title: "Pacote", status: "published")
    @sheet_import = @user.sheet_imports.create!(product: product, status: "completed", imported_at: Time.current)
  end

  test "should get index" do
    get imports_url

    assert_response :success
  end

  test "should show sheet_import" do
    get import_url(@sheet_import)

    assert_response :success
  end
end
