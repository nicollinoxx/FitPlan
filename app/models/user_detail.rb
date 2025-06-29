class UserDetail < ApplicationRecord
  belongs_to :user

  enum :gender, { male: "male", female: "female" }
end
