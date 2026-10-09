class RegistrationsController < ApplicationController
  skip_before_action :authenticate

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_up_path, notice: I18n.t('alert.rate_limit') }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session_record = @user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: session_record.id, httponly: true }

      send_email_verification
      redirect_to sheets_path(format: :html)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.permit(:email, :password, :password_confirmation, :name)
    end

    def send_email_verification
      UserMailer.with(user: @user).email_verification.deliver_later
    end
end
