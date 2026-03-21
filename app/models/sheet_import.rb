class SheetImport < ApplicationRecord
  belongs_to :user
  belongs_to :product

  has_many :sheets, dependent: :nullify

  enum :status, { pending: "pending", completed: "completed", failed: "failed" }

  validates :status, inclusion: { in: statuses.keys }

  scope :recent_first, -> { order(imported_at: :desc, created_at: :desc) }
end
