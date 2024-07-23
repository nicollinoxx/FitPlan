class Identity::EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: :show
  before_action :set_user, only: :show

  def show
    @user.update! verified: true
    redirect_to root_path, notice: I18n.t('identity.show.success')
  end

  def create
    send_email_verification
    redirect_to home_path, notice: I18n.t('identity.create.success')
  end

  private
    def set_user
      @user = User.find_by_token_for!(:email_verification, params[:sid])
    rescue StandardError
      redirect_to edit_identity_email_path, alert: I18n.t('identity.set_user.success')
    end

    def send_email_verification
      UserMailer.with(user: Current.user).email_verification.deliver_later
    end
end
