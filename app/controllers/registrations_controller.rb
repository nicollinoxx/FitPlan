class RegistrationsController < ApplicationController
  skip_before_action :authenticate

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      send_email_verification
    else
      @user.errors.delete(:email, :taken)
      return render :new, status: :unprocessable_entity if @user.errors.any?

      send_account_exists_email
    end

    redirect_to sign_in_path, notice: I18n.t('notice.registration.create', email: @user.email)
  end

  private
    def user_params
      params.permit(:email, :password, :password_confirmation, :name)
    end

    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end

    def send_account_exists_email
      UserMailer.with(user: User.find_by!(email: @user.email)).account_exists.deliver_later
    end
end
