class UserDetail < ApplicationRecord
  belongs_to :user

  validates :height, :weight, numericality: { greater_than: 0 }

  enum :gender, { male: "male", female: "female" }

  before_save :calculate_healthy_metrics

  private

    def calculate_healthy_metrics
      calculate_imc
      calculate_tmb
    end

    def calculate_imc
      self.imc = (weight / (height**2)).round(2)
    end

    def calculate_tmb
      age = ((Time.zone.now - birth_date.to_time) / 1.year).floor

      self.tmb = if male?
        (10 * weight + 6.25 * height * 100 - 5 * age + 5).round(2)
      elsif female?
        (10 * weight + 6.25 * height * 100 - 5 * age - 161).round(2)
      end
    end
end
