class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[ new create ]
  before_action :set_session, only: :destroy

  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end

  def new
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      @session = user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

      redirect_to root_path, notice: I18n.t('sessions.create.success_notice')
    else
      refresh_or_redirect_to sign_in_path(email_hint: params[:email]), notice: I18n.t('sessions.create.success_alert')
    end
  end

  def destroy
    @session.destroy; recede_or_redirect_to(sessions_path, notice: I18n.t('sessions.destroy.success'))
  end

  private
    def set_session
      @session = Current.user.sessions.find(params[:id])
    end
end
