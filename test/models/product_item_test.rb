require "test_helper"

class ProductItemTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @product = @user.products.create!(title: "Pacote", status: "draft")
  end

  test "accepts importable original sheet from same owner" do
    item = @product.product_items.build(sheet: sheets(:importable_workout))
    assert item.valid?
  end

  test "rejects shareable sheet" do
    item = @product.product_items.build(sheet: sheets(:one))
    refute item.valid?
  end
end
