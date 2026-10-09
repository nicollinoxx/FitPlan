class Identity::EmailsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to_root
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      unconfirmed_email, password_challenge = params.expect(:email, :password_challenge)
      { unconfirmed_email:, password_challenge: }
    end

    def redirect_to_root
      resend_email_verification unless User.exists?(email: @user.unconfirmed_email)
      redirect_to identity_settings_path, notice: I18n.t('notice.email.update')
    end

    def resend_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
