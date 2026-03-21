class ProductItem < ApplicationRecord
  belongs_to :product
  belongs_to :sheet

  validates :sheet_id, uniqueness: { scope: :product_id }
  validate :sheet_must_belong_to_product_owner
  validate :sheet_must_be_importable
  validate :sheet_must_be_original

  private

    def sheet_must_belong_to_product_owner
      errors.add(:sheet, :invalid) unless sheet.user_id == product.user_id
    end

    def sheet_must_be_importable
      errors.add(:sheet, :invalid) unless sheet.importable?
    end

    def sheet_must_be_original
      errors.add(:sheet, :invalid) unless sheet.copy?
    end
end
