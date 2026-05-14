class SheetShare < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :sheet_requests, dependent: :destroy

  validates :sender, :recipient, presence: true

  scope :accessible_by, ->(user) { where(sender: user).or(where(recipient: user)) }

  def self.create_with_requests(sender:, recipient:, sheet_ids:)
    return if sheet_ids.blank? || sheet_ids.size > 5

    has_workouts = Workout.where("workouts.sheet_id = sheets.id").arel.exists
    has_diets    = Diet.where("diets.sheet_id = sheets.id").arel.exists

    allowed_ids = sender.sheets.where(id: sheet_ids).where(has_workouts.or(has_diets)).ids
    return if allowed_ids.empty?

    transaction do
      share = create!(sender: sender, recipient: recipient)
      allowed_ids.each do |id|
        share.sheet_requests.create!(sheet_id: id)
      end

      share
    end
  end
end
