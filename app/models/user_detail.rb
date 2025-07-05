class UserDetail < ApplicationRecord
  include BodyMetrics

  belongs_to :user

  validates :height, :weight, :birth_date, :gender, presence: true
  validates :height, :weight, numericality: { greater_than: 0 }
  validates :gender, inclusion: { in: %w[male female] }

  enum :gender, { male: "male", female: "female" }
end
