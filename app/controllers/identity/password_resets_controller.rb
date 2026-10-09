class Identity::PasswordResetsController < ApplicationController
  skip_before_action :authenticate
  before_action :set_user, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_identity_password_reset_path, notice: I18n.t('alert.rate_limit') }

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:email])
    send_password_reset_email if @user

    refresh_or_redirect_to sign_in_path, notice: I18n.t('notice.password_reset.create')
  end

  def update
    if @user.update(user_params.merge(verified: true))
      refresh_or_redirect_to sign_in_path, notice: I18n.t('notice.password_reset.update')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find_by_token_for!(:password_reset, params[:sid])
    rescue StandardError
      refresh_or_redirect_to new_identity_password_reset_path, alert: I18n.t('alert.password_reset.invalid')
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end

    def send_password_reset_email
      UserMailer.with(user: @user).password_reset.deliver_later
    end
end
