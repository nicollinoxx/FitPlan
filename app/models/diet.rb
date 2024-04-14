class Diet < ApplicationRecord
  validates :snack, :description, presence: true
end
