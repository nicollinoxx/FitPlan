class User::HealthCalculator
  def initialize(params)
    @height = params[:height].to_f
    @weight = params[:weight].to_f
    @gender = params[:gender]
    @age    = params[:age].to_i
  end

  def imc
    return 0.0 unless valid_inputs?
    (@weight / (@height * @height)).round(2)
  end

  def tmb
    return 0.0 unless valid_inputs?
    height_cm = @height * 100

    if @gender == 'male'
      (88.362 + (13.397 * @weight) + (4.799 * height_cm) - (5.677 * @age)).round(2)
    else
      (447.593 + (9.247 * @weight) + (3.098 * height_cm) - (4.330 * @age)).round(2)
    end
  end

  private

    def valid_inputs?
      @height > 0.0 && @weight > 0.0
    end
end
