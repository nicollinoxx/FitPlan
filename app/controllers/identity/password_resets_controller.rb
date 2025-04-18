class Identity::PasswordResetsController < ApplicationController
  skip_before_action :authenticate
  before_action :set_user, only: %i[ edit update ]

  def new
  end

  def edit
  end

  def create
    if @user = User.find_by(email: params[:email], verified: true)
      send_password_reset_email
      refresh_or_redirect_to sign_in_path, notice: I18n.t('identity.password_resets.create.success_notice')
    else
      recede_or_redirect_to new_identity_password_reset_path, notice: I18n.t('identity.password_resets.create.success_alert')
    end
  end

  def update
    if @user.update(user_params)
      refresh_or_redirect_to sign_in_path, notice: I18n.t('identity.password_resets.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find_by_token_for!(:password_reset, params[:sid])
    rescue StandardError
      refresh_or_redirect_to new_identity_password_reset_path, alert: I18n.t('identity.password_resets.set_user.success')
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end

    def send_password_reset_email
      UserMailer.with(user: @user).password_reset.deliver_later
    end
end
