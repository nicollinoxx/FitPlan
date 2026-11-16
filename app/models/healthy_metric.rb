class HealthyMetric < ApplicationRecord
  belongs_to :user

  validates :height, :weight, numericality: { greater_than: 0 }, allow_nil: true

  enum :gender, { male: "male", female: "female" }

  before_save :calculate_healthy_metrics

  def age
    ((Time.zone.now - birth_date.to_time) / 1.year).floor if birth_date
  end

  def recommendation_profile
    { gender: gender, age: age, weight_kg: weight&.to_f, height_m: height&.to_f, bmi: imc&.to_f, bmr_kcal: tmb&.to_f }.compact
  end

  private

    def calculate_healthy_metrics
      self.imc = (calculate_imc if height && weight)
      self.tmb = (calculate_tmb if imc && birth_date && gender)
    end

    def calculate_imc
      (weight / (height**2)).round(2)
    end

    def calculate_tmb
      base = 10 * weight + 6.25 * height * 100 - 5 * age
      (male? ? base + 5 : base - 161).round(2)
    end
end
