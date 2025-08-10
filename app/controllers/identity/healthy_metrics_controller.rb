class Identity::HealthyMetricsController < ApplicationController
  before_action :set_user
  before_action :set_healthy_metric, only: %i[ show edit update ]

  def new
    @healthy_metric = @user.build_healthy_metric
  end

  def show
  end

  def edit
  end

  def create
    @healthy_metric = @user.create_healthy_metric!(user_metric_params)
    recede_or_redirect_to identity_healthy_metric_path(@healthy_metric), notice: I18n.t('notice.healthy_metric.create')
  end

  def update
    @healthy_metric.update!(user_metric_params)
    refresh_or_redirect_to identity_healthy_metric_path(@healthy_metric), notice: I18n.t('notice.healthy_metric.update')
  end

  private

  def set_user
    @user = Current.user
  end

  def set_healthy_metric
    @healthy_metric = @user.healthy_metric
  end

  def user_metric_params
    params.expect(healthy_metric: [:height, :weight, :birth_date, :gender])
  end
end
