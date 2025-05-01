class Account::MetricsController < ApplicationController
  before_action :set_user, only: [:edit, :update]

  def edit
  end

  def update
    calculator = HealthCalculatorService.new(metrics_params)

    if @user.update(imc: calculator.imc, tmb: calculator.tmb)
      redirect_to account_path, notice: I18n.t('notice.account_metrics.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def metrics_params
    params.permit(:height, :weight, :gender, :age)
  end
end
