module BodyMetrics
  extend ActiveSupport::Concern

  included do
    before_save :calculate_imc, :calculate_tmb
  end

  private

    def calculate_imc
      self.imc = (weight / (height**2)).round(2)
    end

    def calculate_tmb
      age = ((Time.zone.now - birth_date.to_time) / 1.year).floor

      self.tmb = if self.male?
        (10 * weight + 6.25 * height * 100 - 5 * age + 5).round(2)
      else
        (10 * weight + 6.25 * height * 100 - 5 * age - 161).round(2)
      end
    end
end
