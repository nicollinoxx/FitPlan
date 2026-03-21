require "test_helper"

class ProductTest < ActiveSupport::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @product = @user.products.build(title: "Pacote treino", status: "draft")
  end

  test "is valid with required attributes" do
    assert @product.valid?
  end

  test "sets published_at when published" do
    @product.status = "published"

    @product.save!

    assert_not_nil @product.published_at
  end

  test "imports package as copied sheets grouped by sheet_import" do
    sheet = sheets(:importable_workout)
    sheet.workouts.create!(exercise: "Supino", repetitions: "10", series: 4)
    @product.save!
    @product.product_items.create!(sheet: sheet)

    assert_difference(-> { @user.sheet_imports.count }, 1) do
      assert_difference(-> { @user.sheets.imported.count }, 1) do
        @product.import_to(@user)
      end
    end

    imported_sheet = @user.sheets.imported.order(created_at: :desc).first
    assert_equal sheet, imported_sheet.source_sheet
    assert_equal "marketplace", imported_sheet.origin_type
    assert_equal @product, imported_sheet.sheet_import.product
  end
end
