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
    @user_detail = @user.build_user_detail(user_detail_params)

    if @user_detail.save
      redirect_to @user_detail, notice: I18n.t('notice.user_details.create')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user_detail.update(user_detail_params)
      redirect_to @user_detail, notice: I18n.t('notice.user_details.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def set_user_detail
    @user_detail = @user.user_detail || (raise ActiveRecord::RecordNotFound)
  end

  def user_detail_params
    params.expect(user_detail: [:height, :weight, :birth_date, :gender])
  end
end
