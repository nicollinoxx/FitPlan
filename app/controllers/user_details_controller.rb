class UserDetailsController < ApplicationController
  before_action :set_user
  before_action :set_user_detail, only: %i[ show edit update ]

  def new
    @user_detail = @user.build_user_detail
  end

  def show
  end

  def edit
  end

  def create
    @user_detail = @user.create_user_detail!(user_detail_params)
    refresh_or_redirect_to @user_detail, notice: I18n.t('notice.user_details.create')
  end

  def update
    @user_detail.update!(user_detail_params)
    redirect_to @user_detail, notice: I18n.t('notice.user_details.update')
  end

  private

  def set_user
    @user = Current.user
  end

  def set_user_detail
    @user_detail = @user.user_detail
  end

  def user_detail_params
    params.expect(user_detail: [:height, :weight, :birth_date, :gender])
  end
end
