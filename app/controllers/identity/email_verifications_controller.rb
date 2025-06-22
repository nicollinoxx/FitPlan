class Identity::EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: :show
  before_action :set_user, only: :show

  def show
    @user.update! verified: true
    redirect_to root_path, notice: I18n.t('notice.email_verification.verify')
  end

  def create
    send_email_verification
    redirect_to account_path, notice: I18n.t('notice.email_verification.create')
  end

  private
    def set_user
      @user = User.find_by_token_for!(:email_verification, params[:sid])
    rescue StandardError
      redirect_to edit_identity_email_path, alert: I18n.t('alert.email_verification.invalid')
    end

    def send_email_verification
      UserMailer.with(user: Current.user).email_verification.deliver_later
    end
end
