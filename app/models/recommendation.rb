# A suggestion the AI made for the user, known by the token the page sent when
# it asked. Saving it more than once (a double click, or going back to the
# page and clicking again) does nothing after the first time.
class Recommendation < ApplicationRecord
  belongs_to :user
  belongs_to :sheet, optional: true

  has_many :generated_sheets, class_name: "Sheet", dependent: :nullify

  def accept!
    with_lock do
      next if accepted?

      yield
      update!(accepted_at: Time.current)
    end
  end

  def accepted?
    accepted_at.present?
  end
end
