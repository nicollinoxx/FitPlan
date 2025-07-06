class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :sender, class_name: "User"
  belongs_to :sheet

  validates :sender_id, uniqueness: { scope: :sheet_id }, on: :create
  after_create_commit -> { broadcast_prepend_later_to [:notifications, recipient], target: "notifications", partial: "notifications/notification", locals: { notification: self }}
end
