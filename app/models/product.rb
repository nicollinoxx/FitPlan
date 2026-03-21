class Product < ApplicationRecord
  include Importable

  belongs_to :user

  has_many :product_items, dependent: :destroy, inverse_of: :product
  has_many :sheets, through: :product_items
  has_many :sheet_imports, dependent: :destroy

  enum :status, { draft: "draft", published: "published", archived: "archived" }

  validates :title, presence: true
  validates :status, inclusion: { in: statuses.keys }

  before_save :sync_published_at, if: :will_save_change_to_status?

  private

    def sync_published_at
      self.published_at = published? ? Time.current : nil
    end
end
